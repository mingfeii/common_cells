# CDC 中文教程与配套 RTL

从 [中文教程](docs/CDC教程.md) 开始阅读。本文基于本目录的 Clifford E. Cummings《Clock Domain Crossing (CDC) Design & Verification Techniques Using SystemVerilog》，SNUG Boston 2008，重新组织讲解并独立整理实现。

| 入口 | 内容 |
| --- | --- |
| [详细教程](docs/CDC教程.md) | 从亚稳态到握手、MCP、Gray、FIFO、复位、约束和验证 |
| [代码接口手册](docs/代码接口与集成.md) | 模块选择、接口、参数、集成示例 |
| [仿真说明](sim/README.md) | 一键运行、自检内容、波形信号 |
| [验证结果](docs/验证结果.md) | 实际运行配置、结果和验证边界 |
| [时序约束说明](constraints/README.md) | 同步器、Gray 总线和 bundled-data 的约束要求 |
| [RTL](rtl/) | 7 个可综合模块 |

在项目根目录用 PowerShell 运行：

```powershell
./sim/run.ps1 -Wave
```

默认使用本机 `C:/questasim64_2024.1/win64`。也可指定安装目录：

```powershell
./sim/run.ps1 -QuestaBin 'D:/EDA/questa/win64' -Wave
```

成功时显示 5 行 `PASS`。逐项日志与 VCD 在 `sim/results/`。RTL 不依赖 UVM 或厂商 IP。FIFO 使用异步读的寄存器/分布式 RAM 结构，不能直接替换为同步读块 RAM。

所有双时钟模块采用**共同异步复位源、各时钟域独立同步释放**，共同复位会丢弃在途事务。协议、物理路径约束和同步器 MTBF 都属于正确使用条件。
