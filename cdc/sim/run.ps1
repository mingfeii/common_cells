param(
  [string]$QuestaBin = 'C:/questasim64_2024.1/win64',
  [switch]$Wave
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$build = Join-Path $PSScriptRoot 'build'
$results = Join-Path $PSScriptRoot 'results'
New-Item -ItemType Directory -Force $build, $results | Out-Null
'RUNNING (a new run has not completed yet)' | Set-Content -Encoding utf8 (Join-Path $results 'summary.txt')
function Invoke-Checked([string]$Exe, [string[]]$Arguments, [string]$Log) {
  $output = & (Join-Path $QuestaBin $Exe) @Arguments 2>&1
  $code = $LASTEXITCODE
  $output | Set-Content -Encoding utf8 $Log
  if ($code -ne 0) { $output | Write-Host; throw "$Exe failed: $code" }
  return ($output -join "`n")
}
Push-Location $build
try {
  Invoke-Checked 'vlib.exe' @('work') (Join-Path $results 'vlib.log') | Out-Null
  $rtl = @(Get-ChildItem (Join-Path $root 'rtl/*.sv') | Sort-Object Name | ForEach-Object FullName)
  $compile = @('-sv', '-work', 'work') + $rtl + @((Join-Path $root 'examples/cdc_mailbox_example.sv'), (Join-Path $PSScriptRoot 'tb_cdc.sv'))
  Invoke-Checked 'vlog.exe' $compile (Join-Path $results 'compile.log') | Out-Null
  $cases = @(
    @{Name='fast_to_slow'; Args=@('-gWIDTH=8','-gADDR_WIDTH=3','-gW_HALF=3','-gR_HALF=11','-gR_PHASE=1')},
    @{Name='slow_to_fast'; Args=@('-gWIDTH=17','-gADDR_WIDTH=2','-gW_HALF=11','-gR_HALF=3','-gR_PHASE=2')},
    @{Name='coincident'; Args=@('-gWIDTH=32','-gADDR_WIDTH=3','-gW_HALF=5','-gR_HALF=5','-gR_PHASE=0')},
    @{Name='depth2_width1'; Args=@('-gWIDTH=1','-gADDR_WIDTH=1','-gW_HALF=4','-gR_HALF=7','-gR_PHASE=1')},
    @{Name='three_stages'; Args=@('-gWIDTH=16','-gADDR_WIDTH=4','-gSTAGES=3','-gW_HALF=5','-gR_HALF=8','-gR_PHASE=3')}
  )
  $summary = @()
  foreach ($case in $cases) {
    $argsSim = @('-c','-voptargs=+acc','-onfinish','exit','tb_cdc') + @($case.Args | ForEach-Object { $_ -replace '^-g', '-g/tb_cdc/' })
    if ($Wave) { $argsSim += '+VCD' }
    $argsSim += @('-do','onerror {quit -code 1}; onbreak {quit -code 1}; run -all; quit -code 0')
    $log = Join-Path $results ($case.Name+'.log')
    $output = Invoke-Checked 'vsim.exe' $argsSim $log
    if ($output -notmatch 'ALL PASS' -or $output -match '\*\* (Error|Fatal)') { throw "Missing PASS or simulator error: $log" }
    if ($Wave) { Move-Item -Force -LiteralPath (Join-Path $build 'cdc.vcd') -Destination (Join-Path $results ($case.Name+'.vcd')) }
    $summary += "PASS $($case.Name)"
    Write-Host $summary[-1]
  }
  $summary | Set-Content -Encoding utf8 (Join-Path $results 'summary.txt')
} finally { Pop-Location }
