"""Render the first single-word transaction from actual VCD to readable SVG.

No plotting dependency. Supports the scalar and integer top-level signals used
here, in Questa/Icarus VCD files. Run after: python sim/run.py --quick --vcd
"""
from bisect import bisect_right
from html import escape
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]


def load_vcd(path):
    scope, codes, events = [], {}, {}
    now, unit = 0, 0.001  # default one ps in ns
    text = path.read_text(encoding='ascii', errors='replace')
    ts = re.search(r'\$timescale\s+(\d+)\s*(fs|ps|ns|us)\s+\$end', text)
    if ts:
        unit = int(ts[1]) * {'fs': 1e-6, 'ps': 1e-3, 'ns': 1, 'us': 1000}[ts[2]]
    for line in text.splitlines():
        p = line.split()
        if not p:
            continue
        if p[0] == '$scope':
            scope.append(p[2])
        elif p[0] == '$upscope':
            scope.pop()
        elif p[0] == '$var' and scope == ['tb_async_fifo']:
            if p[4] in ['wclk', 'rclk', 'winc', 'rinc', 'wfull', 'rempty', 'occupancy', 'writes', 'reads']:
                codes[p[3]] = p[4]
                events[p[4]] = []
        elif line.startswith('#'):
            now = int(line[1:]) * unit
        elif line[0] in '01xXzZbB':
            if line[0] in 'bB':
                bits, code = p[0][1:], p[1]
            else:
                bits, code = line[0], line[1:].strip()
            if code in codes:
                value = None if re.search('[xz]', bits.lower()) else int(bits, 2)
                ev = events[codes[code]]
                if ev and ev[-1][0] == now:
                    ev[-1] = (now, value)
                elif not ev or ev[-1][1] != value:
                    ev.append((now, value))
    return events


def render(style):
    path = ROOT / f'sim/build/s{style}_a4_d8_w3_r5_p1_seed1/wave.vcd'
    ev = load_vcd(path)
    write = next(t for t, v in ev['writes'] if v == 1)
    read = next(t for t, v in ev['reads'] if v == 1)
    visible = next(t for t, v in ev['rempty'] if t >= write and v == 0)
    start, stop = write - 12, read + 15
    left, right = 170, 1035
    def x(t):
        return left + (t-start)/(stop-start)*(right-left)
    rows = [('wclk', '写时钟'), ('winc', '写请求'), ('wfull', '满标志'),
            ('rclk', '读时钟'), ('rinc', '读请求'), ('rempty', '空标志'),
            ('occupancy', '真实占用量')]
    parts = [f'<svg xmlns="http://www.w3.org/2000/svg" width="1100" height="555" viewBox="0 0 1100 555">',
             '<rect width="1100" height="555" fill="#f8fafc"/>',
             '<style>text{font-family:Microsoft YaHei,Arial,sans-serif;fill:#172b45}.small{font-size:12px}.label{font-size:14px}</style>',
             f'<text x="30" y="34" font-size="21" font-weight="bold">Style #{style} · 第一项数据从写入到读出</text>',
             '<text x="30" y="61" class="label">实际 Questa RTL 波形；深度 16，8 位数据；写周期 6 ns，读周期 10 ns</text>']
    for t in range(int(start//10*10), int(stop)+1, 10):
        if t < start:
            continue
        xx=x(t)
        parts.append(f'<path d="M {xx:.2f} 105 V 465" stroke="#e0e6ee"/>')
        parts.append(f'<text x="{xx:.2f}" y="487" class="small" text-anchor="middle">{t}</text>')
    for i, (signal, label) in enumerate(rows):
        base=132+i*47
        parts.append(f'<text x="25" y="{base-8}" class="label">{escape(signal)}</text>')
        parts.append(f'<text x="25" y="{base+9}" class="small">{label}</text>')
        values=ev[signal]
        idx=bisect_right([t for t, _ in values], start)-1
        initial=values[idx][1] if idx>=0 else 0
        points=[(start, initial)] + [(t,v) for t,v in values if start<t<stop] + [(stop, None)]
        color='#9b3fba' if signal=='occupancy' else '#087f8c'
        d=[]
        prev=initial
        for j,(t,value) in enumerate(points):
            y=base-(22 if prev else 0)
            if j==0:
                d.append(f'M {x(t):.2f} {y}')
            else:
                d.append(f'H {x(t):.2f}')
            if value is not None:
                new_y=base-(22 if value else 0)
                d.append(f'V {new_y}')
                prev=value
        parts.append(f'<path d="{" ".join(d)}" fill="none" stroke="{color}" stroke-width="2"/>')
    for t, label, col, yy in [(write,'接受第 1 次写','#b55b08',85),
                              (visible,'解除空标志','#7b3ab2',100),
                              (read,'接受第 1 次读','#1f6d3c',85)]:
        xx=x(t)
        parts.append(f'<path d="M {xx:.2f} 107 V 458" stroke="{col}" stroke-dasharray="4 4"/>')
        parts.append(f'<text x="{xx:.2f}" y="{yy}" fill="{col}" class="small" text-anchor="middle">{label} {t:g} ns</text>')
    parts.extend(['<text x="1035" y="510" class="small" text-anchor="end">时间 / ns</text>',
                  '<text x="30" y="536" class="label">读请求由测试场景稍后发出；标志解除与实际消费是两个不同事件。0 / 1 分别画在每行低 / 高位置。</text>', '</svg>'])
    out=ROOT / f'docs/figures/style{style}_first_word.svg'
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text('\n'.join(parts), encoding='utf-8')
    print(f'Style {style}: write={write:g} ns, empty_release={visible:g} ns, read={read:g} ns -> {out}')


if __name__ == '__main__':
    for selected_style in (1, 2):
        render(selected_style)
