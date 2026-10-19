# 异步 FIFO 学习工程：从同步指针比较到异步象限比较

依据目录中的两篇 Cummings 论文 Rev 1.2 整理。这里是**有来源对照的教学重写**，不是逐字抄录，也不声称完成了芯片级 CDC/时序签核。RTL 使用 `.sv` 文件，主体采用直观的 Verilog 寄存器和组合逻辑写法。

**建议顺序：先跑仿真 → 阅读 Style #1 → 看满空波形 → 最后学习 Style #2。**

## 从这里开始

- [详细中文教程](docs/异步FIFO教程.md)：原理、公式推导、代码导读、时序分析、工程注意事项和练习。
- [论文与代码对照](docs/论文对照与改动.md)：每个模块的出处、修订说明和本工程的有意改动。
- [实测仿真报告](docs/仿真报告.md)：运行环境、参数矩阵、检查内容和结果。
- [接入示例](examples/async_fifo_example.sv)：同一个复位请求分别在两个时钟域同步释放。

## 目录

```text
rtl/common/  fifo_mem.sv、reset_sync.sv
rtl/style1/  async_fifo_style1.sv、gray_sync.sv、s1_write_ptr.sv、s1_read_ptr.sv
rtl/style2/  async_fifo_style2.sv、s2_async_cmp.sv、s2_write_ptr.sv、s2_read_ptr.sv
tb/          tb_async_fifo.sv：逐笔数据自检、边界测试和随机测试
sim/         run.py：自动回归；waves.do：Questa 波形配置
sim/build/   实际运行生成的日志、结果 JSON、VCD 和仿真器文件
docs/        教程、论文对照、仿真报告
examples/    Style #1 接入示例
```

## 运行

需要 Python 3.9+，以及 PATH 中的 Questa (`vlib/vlog/vsim`) 或 Icarus (`iverilog/vvp`)。Python 脚本仅依赖标准库。此电脑已用 QuestaSim 2024.1 执行验证。

在工程根目录打开终端：

```powershell
# 两个实现各跑一次，同时产生波形，适合第一次学习
python sim/run.py --sim questa --quick --vcd

# 完整回归：33 组参数/时钟/随机种子组合
python sim/run.py --sim questa --vcd

# 仅运行主线实现
python sim/run.py --sim questa --style 1 --quick --vcd

# 如果装的是 Icarus，可以切换工具；本次没有实测这一工具分支
python sim/run.py --sim iverilog --quick --vcd
```

脚本在任意检查失败、仿真器错误、超时或缺少 `PASS` 时返回非零状态。每次运行重写 `sim/build/results.json`；各用例的日志在独立子目录中。`--quick` 会以相同参数重写其对应的用例日志。

波形示例：

```powershell
# 安装 GTKWave 后，可直接打开 VCD
gtkwave sim/build/s1_a4_d8_w3_r5_p1_seed1/wave.vcd

# 或使用本机 Questa 图形界面；从对应用例目录启动
cd sim/build/s1_a4_d8_w3_r5_p1_seed1
vsim -gui -voptargs=+acc -lib ../work tb_async_fifo -gSTYLE=1 -do ../../waves.do
```

Style #2 例子将目录中的 `s1_...` 换成 `s2_...`，同时使用 `-gSTYLE=2`。GUI 命令会重新仿真；原始回归日志和 VCD 仍可直接查看。

教程已附两幅从实际 VCD 生成的 SVG 时序图。重新生成可执行 `python sim/render_wave.py`，不需要额外 Python 库。

## 接口约定

两个顶层使用相同接口：

| 信号 | 所属域 | 含义 |
|---|---|---|
| `wclk / wrst_n` | 写域 | 写时钟 / 低有效写域复位 |
| `winc / wdata` | 写域 | 写请求 / 待写数据 |
| `wfull` | 写域 | 满，必须停止接受新数据 |
| `rclk / rrst_n` | 读域 | 读时钟 / 低有效读域复位 |
| `rinc / rdata` | 读域 | 读请求 / 当前队首数据 |
| `rempty` | 读域 | 空，输出数据无效 |

在正常工作且本地域已退出复位时，写接受条件是 `winc && !wfull`，读接受条件是 `rinc && !rempty`，分别在本地域上升沿采样。`winc/rinc` 可以连续保持为 1；被阻止的请求不会推进指针，满时也不会写坏存储器。

存储器采用**同步写、异步读 / FWFT**，接收端在有效读沿采样沿前的 `rdata`。这不是通用的同步读 BRAM 接口，不能只替换 RAM 而忽略读延迟。

`DEPTH = 2**ADDR_WIDTH`。Style #1 支持 `ADDR_WIDTH>=1`；Style #2 的象限判断要求 `ADDR_WIDTH>=2`。两域复位来自**同一个清空请求**，分别同步释放；单独复位一个域不在接口保证范围内。

## 两种实现的定位

| 项目 | Style #1：学习主线 | Style #2：进阶研究 |
|---|---|---|
| 跨域信息 | Gray 指针经过两级同步 | Gray 指针直接异步比较 |
| 满空判断 | 本地域同步比较并寄存 | 象限方向锁存 + 指针相等比较 |
| 指针宽度 | 地址位数 + 1 | 地址位数 |
| 标志置位 | 本地域寄存器时钟沿更新 | 通过异步控制端置位 |
| 标志解除 | 同步指针传播后更新 | 两拍同步解除 |
| 工程关注点 | 同步器、Gray 总线约束、RAM、复位 | 另需 SR 锁存器、异步 preset/reset 映射和专门时序分析 |

第二篇论文自身的修订说明强调了 Style #2 对 STA/DFT 的困难。这里保留它是为了理解论文中的巧妙方法；普通工程接入优先沿 Style #1 的结构完成目标器件验证。

论文作者：Clifford E. Cummings；第二篇合作者 Peter Alfke。仿真器参考：[Icarus 官方文档](https://steveicarus.github.io/iverilog/)。
