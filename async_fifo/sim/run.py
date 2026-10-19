"""Run RTL self-checking regressions using Questa or Icarus (Python stdlib only)."""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]
SOURCES = (sorted((ROOT / 'rtl').rglob('*.sv'))
           + sorted((ROOT / 'examples').glob('*.sv'))
           + [ROOT / 'tb/tb_async_fifo.sv'])


def command(args, cwd, log):
    result = subprocess.run([str(x) for x in args], cwd=cwd, text=True,
                            stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            encoding='utf-8', errors='replace', timeout=120)
    with log.open('a', encoding='utf-8') as f:
        f.write('$ ' + ' '.join(str(x) for x in args) + '\n' + result.stdout + '\n')
    if result.returncode or '** Error' in result.stdout or '** Fatal' in result.stdout:
        raise RuntimeError(result.stdout[-6000:])
    return result.stdout


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--sim', choices=['auto', 'questa', 'iverilog'], default='auto')
    p.add_argument('--quick', action='store_true', help='one run per style')
    p.add_argument('--style', type=int, choices=[1, 2])
    p.add_argument('--vcd', action='store_true')
    args = p.parse_args()
    sim = args.sim
    if sim == 'auto':
        sim = 'iverilog' if shutil.which('iverilog') and shutil.which('vvp') else 'questa'
    required = ['iverilog', 'vvp'] if sim == 'iverilog' else ['vlib', 'vlog', 'vsim']
    missing = [tool for tool in required if not shutil.which(tool)]
    if missing:
        p.error('Missing simulator programs in PATH: ' + ', '.join(missing))
    output = ROOT / 'sim/build'
    output.mkdir(parents=True, exist_ok=True)
    compile_log = output / 'compile.log'
    compile_log.write_text('', encoding='utf-8')
    if sim == 'questa':
        if not (output / 'work').exists():
            command(['vlib', 'work'], output, compile_log)
        command(['vlog', '-sv', '-work', 'work', *SOURCES], output, compile_log)
    # (address bits, data width, write half-period, read half-period, phase)
    cases = [(4, 8, 3, 5, 1)] if args.quick else [
        (1, 1, 3, 5, 1), (2, 8, 3, 11, 0), (3, 17, 11, 3, 1),
        (4, 8, 3, 5, 1), (4, 32, 5, 5, 0), (5, 17, 2, 13, 1)]
    seeds = [1] if args.quick else [1, 42, 2026]
    styles = [args.style] if args.style else [1, 2]
    summary = []
    for style in styles:
        for aw, dw, wh, rh, phase in cases:
            if style == 2 and aw < 2:
                continue
            for seed in seeds:
                name = f's{style}_a{aw}_d{dw}_w{wh}_r{rh}_p{phase}_seed{seed}'
                case_dir = output / name
                case_dir.mkdir(exist_ok=True)
                log = case_dir / 'run.log'
                log.write_text('', encoding='utf-8')
                params = dict(STYLE=style, ADDR_WIDTH=aw, DATA_WIDTH=dw,
                              W_HALF=wh, R_HALF=rh, R_PHASE=phase)
                plus = [f'+SEED={seed}'] + (['+VCD'] if args.vcd else [])
                start = time.monotonic()
                if sim == 'questa':
                    # Explicit library path lets each case keep its own waveform/log.
                    lib = str(output / 'work').replace('\\', '/')
                    text = command(['vsim', '-c', '-voptargs=+acc', '-onfinish', 'stop', '-lib', lib,
                                    *[f'-g{k}={v}' for k, v in params.items()],
                                    'tb_async_fifo', *plus, '-do',
                                    'onerror {quit -code 1}; onbreak {quit -code 1}; run -all; quit -code 0'], case_dir, log)
                else:
                    exe = case_dir / 'test.vvp'
                    command(['iverilog', '-g2012', '-Wall', '-s', 'tb_async_fifo',
                             *[f'-Ptb_async_fifo.{k}={v}' for k, v in params.items()],
                             '-o', exe, *SOURCES], case_dir, log)
                    text = command(['vvp', exe, *plus], case_dir, log)
                passes = [line for line in text.splitlines() if 'PASS style=' in line]
                if len(passes) != 1:
                    raise RuntimeError(f'{name}: missing unique PASS marker, see {log}')
                if args.vcd:
                    wave = case_dir / 'wave.vcd'
                    if not wave.exists() or '$var ' not in wave.read_text(encoding='ascii', errors='replace'):
                        raise RuntimeError(f'{name}: waveform contains no signal declarations')
                print(passes[0].removeprefix('# '), flush=True)
                summary.append(dict(case=name, simulator=sim, parameters=params,
                                    seed=seed, result='PASS', evidence=passes[0],
                                    seconds=round(time.monotonic()-start, 3)))
    (output / 'results.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
    print(f'ALL PASS: {len(summary)} cases. Results: {output / "results.json"}')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, subprocess.TimeoutExpired) as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
