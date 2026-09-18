# Arbiter RTL and simulation

SystemVerilog implementations of the four arbiters described in the referenced
tutorial:

- `fixed_arbiter.sv`: combinational fixed priority, port 0 highest.
- `rr_arbiter.sv`: mask-based round-robin arbitration.
- `wrr_arbiter.sv`: smooth/interleaved weighted round-robin using credit counters.
- `matrix_arbiter.sv`: matrix/LRU round-robin arbitration.

All request and grant vectors are one-hot oriented: a grant is either zero or has
exactly one bit set. State-based arbiters update on an effective grant. For WRR,
`busy=1` holds the credit counters and rotation pointer; the requester must keep
its request stable until the grant is accepted. Every configured WRR weight must
be greater than zero.

Run the self-checking Questa simulation from this directory:

```tcl
vsim -c -do sim.tcl
```

The testbench checks fixed priority, RR and matrix rotation, inactive-port skips,
WRR 4:3:2:1 allocation, busy-state holding, and randomized one-hot/request-mask
invariants. A successful run prints:

```text
PASS: all arbiter tests completed successfully
```

For an interactive waveform session, compile with `sim.tcl` after removing its
`-c`/`quit` flow, then execute `do wave.do` in the Questa transcript.
