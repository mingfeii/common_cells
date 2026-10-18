# 自检仿真运行说明

在项目根目录运行：

```powershell
./sim/run.ps1 -Wave
```

依赖 Siemens Questa/ModelSim 的 `vlib/vlog/vsim`，以及可用的仿真许可证。脚本默认路径为本机 `C:/questasim64_2024.1/win64`，可用 `-QuestaBin` 修改。当前已实际验证 Questa 2024.1。

不需要波形时省略 `-Wave`。脚本在 `sim/build` 编译和运行，在 `sim/results` 写日志。每组运行要求仿真器成功返回、日志无 Error/Fatal，并且出现 `ALL PASS`，否则脚本失败。

## 五组回归

| 名称 | 数据宽度 | 通用 FIFO 深度 | 同步级数 | 写周期 | 读周期 | 读时钟初始相移 |
| --- | --- | --- | --- | --- | --- | --- |
| fast_to_slow | 8 | 8 | 2 | 6 ns | 22 ns | 1 ns |
| slow_to_fast | 17 | 4 | 2 | 22 ns | 6 ns | 2 ns |
| coincident | 32 | 8 | 2 | 10 ns | 10 ns | 0 ns |
| depth2_width1 | 1 | 2 | 2 | 8 ns | 14 ns | 1 ns |
| three_stages | 16 | 16 | 3 | 10 ns | 16 ns | 3 ns |

这里的相移是读时钟振荡开始前的延时，读第一个上升沿发生在相移加读半周期处。所有配置都同时测试 MCP 集成例子、单笔 FIFO、通用 FIFO、事件握手、4 bit Gray 计数器、1 bit 电平同步和本地复位同步器。

## 自检内容

- 目的端禁止读取，确认邮箱/单笔 FIFO 容量是 1，通用 FIFO 容量为指定深度，满时不再接受写入。
- 每个已接受字进入独立队列记分板，消费时逐笔比对，检查顺序、内容、丢失和重复。
- 连续运行足以使通用 FIFO 指针多次回绕，并检查占用不超过容量。
- 源 valid 等待 ready，目的端随机背压；检查输出在停顿期间保持 valid 和数据。
- 统计已接受事件和收到事件脉冲，检查脉冲宽度为一个目的周期。
- 对 Gray 计数检查源二进制序列、Gray 编码、源端一位变化、目的 RTL 同步级数、解码和停止后的收敛。
- 对同步器核对数字仿真中的流水线延迟；对复位核对异步断言和本地 STAGES 个边沿后释放。
- 两轮完整流量之间进行活动期共同复位，清空在途事务并重新测试；结束前再次共同复位。
- 2 ms 仿真时间 watchdog 防止死锁永远不结束。

发送与背压使用每条流各自的确定性 xorshift 序列，结果可以复现；不是每次运行改变种子的穷举测试。测试没有注入真实亚稳态，也没有随机增加同步器恢复周期。

## 查看日志和波形

`summary.txt` 是最近运行状态。成功显示 5 项 PASS；每项详细日志有两个 epoch 的流量统计，以及最后的 `ALL PASS`。编译日志为 `compile.log`。

启用 `-Wave` 后生成同名 VCD，例如 `fast_to_slow.vcd`。可以在支持 VCD 的波形工具中打开，或在 Questa GUI 导入 VCD。GUI 调试时也可进入 `sim/build`，装载 `work.tb_cdc` 后自行加波形运行。

| 观察对象 | 典型层次/信号 |
| --- | --- |
| MCP | `tb_cdc.a.g_mcp.dut.u_mailbox` 下的 req、ack、hold_data、req_sync、ack_sync |
| 单笔 FIFO | `tb_cdc.b.g_one.dut` 下的 wptr、rptr、wptr_sync、rptr_sync |
| 通用 FIFO | `tb_cdc.c.g_fifo.dut` 下的 wbin、rbin、wgray、rgray 以及同步指针 |
| 流接口 | a/b/c 下的 wvalid、wready、wdata、rvalid、rready、rdata |
| 事件 | `tb_cdc.u_event` 及顶层 events_sent/events_received |
| Gray | `tb_cdc.u_count`、src_bin、src_gray、dst_bin、dst_gray |

Questa 默认不一定把 unpacked memory 全部导出到 VCD；可通过 hold_data、指针、接口数据和事务计数观察主要行为。脚本启用 `+acc` 保持调试可见性，因此工具可能提示优化受限，这是波形可见性提示。

## 验证范围

当前是零延迟 RTL 功能回归。没有执行门级 SDF、形式穷举、综合/布局或器件 MTBF 签核。没有测试一侧独立复位；这是模块接口明确不支持的条件。物理时序要求见 [约束说明](../constraints/README.md)。
