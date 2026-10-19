"""Make a readable, evidence-based Chinese report after the full regression."""
from datetime import datetime, timedelta, timezone
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
rows = json.loads((ROOT / 'sim/build/results.json').read_text(encoding='utf-8'))
if len(rows) != 33 or any(r['result'] != 'PASS' for r in rows):
    raise SystemExit('Run the full 33-case regression before generating this report.')
keys = ['writes', 'reads', 'blocked_w', 'blocked_r', 'simultaneous']
totals = {k: sum(int(re.search(k + r'=(\d+)', r['evidence'])[1]) for r in rows) for k in keys}
parts = [
    '# 异步 FIFO 实测仿真报告', '',
    f'报告生成时间：{datetime.now(timezone(timedelta(hours=8))).strftime("%Y-%m-%d %H:%M:%S")}（Asia/Shanghai）。', '',
    '## 1. 结论与环境', '',
    '**33/33 组全部通过**：Style #1 共 18 组，Style #2 共 15 组。', '',
    '- 仿真器：本机 QuestaSim-64 2024.1，Windows。',
    '- 执行命令：`python sim/run.py --sim questa --vcd`。',
    '- 编译：RTL、接入示例和测试平台均已编译，Errors=0 / Warnings=0。',
    '- 保留信号：`-voptargs=+acc`，解决默认优化后 VCD 可能缺少信号的问题。',
    '- 仿真中的 `vopt-10587` 是保留调试信号导致部分优化关闭的提示，日志完整保留。',
    '- Icarus 分支已提供，本次未安装/运行，不能把本次结果表述为双工具验证。', '',
    f'累计有效写入 **{totals["writes"]:,}** 次、逐笔核对有效读取 **{totals["reads"]:,}** 次；'
    f'满时写请求被阻止 **{totals["blocked_w"]:,}** 次、空时读请求被阻止 **{totals["blocked_r"]:,}** 次；'
    f'同一时间接受读写 **{totals["simultaneous"]:,}** 次。', '',
    '累计写数与读数不相等是预期行为：每例都在填满后执行运行中复位，丢弃当时全部数据。当前占用量在结束时已经排空。', '',
    '## 2. 参数矩阵', '',
    '每组时钟/参数分别使用随机种子 1、42、2026。半周期单位为 ns；读时钟初相位同样以 ns 表示。', '',
    '| 地址位数 / 深度 | 数据宽度 | 写半周期 | 读半周期 | 读相位 | Style #1 | Style #2 |',
    '|---|---:|---:|---:|---:|---|---|',
    '| 1 / 2 | 1 | 3 | 5 | 1 | 3 PASS | 不支持，象限需至少 2 位 |',
    '| 2 / 4 | 8 | 3 | 11 | 0 | 3 PASS | 3 PASS |',
    '| 3 / 8 | 17 | 11 | 3 | 1 | 3 PASS | 3 PASS |',
    '| 4 / 16 | 8 | 3 | 5 | 1 | 3 PASS | 3 PASS |',
    '| 4 / 16 | 32 | 5 | 5 | 0 | 3 PASS | 3 PASS |',
    '| 5 / 32 | 17 | 2 | 13 | 1 | 3 PASS | 3 PASS |', '',
    '## 3. 每例执行的检查', '',
    '复位空状态、空读、单项首字读取、三轮填满/排空、满时额外写、空时额外读、'
    '4000 个写周期随机请求、1000 个写周期连续双向请求、停止读时钟、停止写时钟、'
    '有未读数据时的共同复位、复位后再次填满/排空。', '',
    '每个被接受的读均逐笔比较数据；独立事务模型检查容量边界；同时检查源 Gray 的单步变化、'
    '未接受操作时指针保持、标志非未知值、覆盖门槛和全局超时。等频同相用例要求实际接受过同沿读写。', '',
    '这不是断言所有瞬间的 full/empty 与真实占用量完全相同：跨域信息具有保守延迟，允许暂时阻止安全但尚未被本地域确认的操作。', '',
    '## 4. 全部运行证据', '',
    '各行的计数来自实际日志 `PASS` 行；明细日志位于 `sim/build/<用例>/run.log`。', '',
    '| 用例 | 有效写 | 核对读 | 阻止写 | 阻止读 | 同沿读写 | 结果 |',
    '|---|---:|---:|---:|---:|---:|---|',
]
for r in rows:
    vals = [int(re.search(k + r'=(\d+)', r['evidence'])[1]) for k in keys]
    wave = ROOT / 'sim/build' / r['case'] / 'wave.vcd'
    if not wave.exists() or '$var ' not in wave.read_text(encoding='ascii', errors='replace'):
        raise SystemExit(f'Missing real waveform: {wave}')
    parts.append('| `' + r['case'] + '` | ' + ' | '.join(str(v) for v in vals) + ' | PASS |')
parts += [
    '', '## 5. 波形实例', '',
    'Style #1：255 ns 接受第一项写入，276 ns 解除空，326 ns 消费第一项。', '',
    '![Style #1 首项实际波形](figures/style1_first_word.svg)', '',
    'Style #2：255 ns 接受第一项写入，266 ns 解除空，326 ns 消费第一项。读请求由场景稍后发出，因此读出时间相同。', '',
    '![Style #2 首项实际波形](figures/style2_first_word.svg)', '',
    '## 6. 证据文件与可复现性', '',
    '- `sim/build/compile.log`：本次编译日志。',
    '- `sim/build/results.json`：33 组结果和参数。',
    '- `sim/build/<用例>/run.log`：每组场景、PASS 计数及仿真器消息。',
    '- `sim/build/<用例>/wave.vcd`：已确认含信号声明的实际波形。',
    '- `python sim/render_wave.py`：重绘两张教学时序图。',
    '- `python sim/make_report.py`：完整回归后重建本报告。', '',
    '以下 SHA-256 标识本报告对应的 RTL、测试平台及接入示例快照；修改源码后应重新执行回归。', '',
    '| 文件 | SHA-256 |', '|---|---|',
]
for f in sorted((ROOT / 'rtl').rglob('*.sv')) + sorted((ROOT / 'tb').glob('*.sv')) + sorted((ROOT / 'examples').glob('*.sv')):
    parts.append(f'| `{f.relative_to(ROOT).as_posix()}` | `{hashlib.sha256(f.read_bytes()).hexdigest()}` |')
parts += ['', '## 7. 验证边界', '',
          '本次验证没有覆盖真实亚稳态、门级延迟、Gray 总线物理偏斜、实际 RAM 宏、SR 锁存器和异步控制寄存器的映射、'
          'STA/CDC/DFT 签核，也没有声称穷尽所有时钟相位与序列。Style #2 的异步比较机制仍需按第二篇论文讨论的条件完成目标工艺检查。', '']
(ROOT / 'docs/仿真报告.md').write_text('\n'.join(parts), encoding='utf-8')
print(f'Generated report: {len(rows)} PASS cases; reads={totals["reads"]}')
