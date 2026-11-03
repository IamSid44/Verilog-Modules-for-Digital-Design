# Verilog Modules for Digital Design

A small library of simple, readable Verilog modules for the standard digital
design building blocks: gates, multiplexers, decoders, adders, flip-flops,
shift registers, counters and finite state machines. Every module has a
self-checking testbench, so you can copy a module out and trust it.

It started as coursework for *VLSI Design* (IIIT Hyderabad) and was then cleaned
up into a reference repo. The code is plain Verilog-2001/2005 and is simulated
with [Icarus Verilog](https://steveicarus.github.io/iverilog/).

## Quick start

Install Icarus Verilog (`iverilog` and `vvp`) and optionally GTKWave, then:

```sh
scripts/run_tests.sh              # compile every module, then run every testbench
scripts/run_tests.sh mux          # only testbenches whose name contains "mux"
scripts/run_tests.sh --vcd fsm    # also write build/waves/fsm_tb.vcd
gtkwave build/waves/fsm_tb.vcd    # view it
```

Each testbench prints `PASS: <name>` or `FAIL: <name>` with the failing cases,
and the script exits non-zero if anything fails. On Windows, run it from Git
Bash.

## Using a module in your own project

Every file `include`s the files it depends on (with include guards, so shared
modules are only defined once), so any single file compiles on its own. The
include paths are relative to the repository root, so run `iverilog` from there:

```sh
iverilog -g2005 -o my_design.vvp my_testbench.v   # my_testbench.v includes "rtl/sequential/dff.v" etc.
vvp my_design.vvp
```

In VS Code the Verilog linter runs from the workspace folder by default, so
opening the repo root as the workspace works without any settings.

To reuse a module in another project, copy it together with the files listed
under "Uses" below and fix the `include` paths.

## Module index

### Combinational: [`rtl/combinational/`](rtl/combinational)

| Module | Description | Uses |
|---|---|---|
| [`basic_gates`](rtl/combinational/basic_gates.v) | AND, OR, NAND, NOR, XOR, XNOR, NOT from gate primitives | |
| [`compound_1`](rtl/combinational/compound_1.v) | Y = AB + CD, NAND only | |
| [`compound_2`](rtl/combinational/compound_2.v) | Y = (ABC + DE)·F, NAND only | |
| [`compound_3`](rtl/combinational/compound_3.v) | Y = ((A + B')(CD + E))', NAND only | |
| [`compound_4`](rtl/combinational/compound_4.v) | F(A,B,C,D) = ΠM(1,3,5,7,13,15), NAND only | |
| [`compound_5`](rtl/combinational/compound_5.v) | F(A,B,C,D) = Σm(0,6,8,13,14) + d(2,4,10), NAND only | |
| [`mux2to1`](rtl/combinational/mux2to1.v) | 2:1 multiplexer from gates | |
| [`mux4to1`](rtl/combinational/mux4to1.v) | 4:1 multiplexer | `mux2to1` |
| [`mux8to1`](rtl/combinational/mux8to1.v) | 8:1 multiplexer | `mux4to1`, `mux2to1` |
| [`demux1to2`](rtl/combinational/demux1to2.v) | 1:2 demultiplexer from gates | |
| [`demux1to4`](rtl/combinational/demux1to4.v) | 1:4 demultiplexer | `demux1to2` |
| [`demux1to8`](rtl/combinational/demux1to8.v) | 1:8 demultiplexer | `demux1to4`, `demux1to2` |
| [`decoder1to2`](rtl/combinational/decoder1to2.v) | 1-to-2 decoder with enable, from gates | |
| [`decoder2to4`](rtl/combinational/decoder2to4.v) | 2-to-4 decoder with enable | `decoder1to2` |
| [`decoder3to8`](rtl/combinational/decoder3to8.v) | 3-to-8 decoder with enable | `decoder2to4`, `decoder1to2` |
| [`priority_encoder_8to3`](rtl/combinational/priority_encoder_8to3.v) | 8-to-3 priority encoder with enable and `valid` | |

### Arithmetic: [`rtl/arithmetic/`](rtl/arithmetic)

| Module | Description | Uses |
|---|---|---|
| [`full_adder`](rtl/arithmetic/full_adder.v) | 1-bit full adder from gates (two half adders and an OR) | |
| [`ripple_adder_4bit`](rtl/arithmetic/ripple_adder_4bit.v) | 4-bit ripple-carry adder | `full_adder` |
| [`ripple_adder_16bit`](rtl/arithmetic/ripple_adder_16bit.v) | 16-bit ripple-carry adder (4 × 4-bit) | `ripple_adder_4bit` |
| [`cla_lookahead_4`](rtl/arithmetic/cla_lookahead_4.v) | 4-position carry-lookahead unit (carries plus group propagate/generate) | |
| [`cla_4bit`](rtl/arithmetic/cla_4bit.v) | 4-bit carry-lookahead adder | `cla_lookahead_4` |
| [`cla_16bit`](rtl/arithmetic/cla_16bit.v) | 16-bit two-level carry-lookahead adder (4 × `cla_4bit` plus a second lookahead unit) | `cla_4bit`, `cla_lookahead_4` |

### Sequential: [`rtl/sequential/`](rtl/sequential)

| Module | Description | Uses |
|---|---|---|
| [`dff`](rtl/sequential/dff.v) | D flip-flop | |
| [`tff`](rtl/sequential/tff.v) | T flip-flop (reset value is a parameter) | |
| [`jkff`](rtl/sequential/jkff.v) | JK flip-flop | |
| [`srff`](rtl/sequential/srff.v) | Clocked S-R flip-flop | |
| [`sr_latch`](rtl/sequential/sr_latch.v) | Level-sensitive S-R latch | |
| [`universal_shift_reg`](rtl/sequential/universal_shift_reg.v) | N-bit shift register: hold, shift right, shift left, parallel load | `mux4to1`, `dff` |
| [`serial_adder`](rtl/sequential/serial_adder.v) | N-bit serial adder (one bit per clock) | `universal_shift_reg`, `full_adder`, `dff` |
| [`ripple_counter`](rtl/sequential/ripple_counter.v) | N-bit asynchronous (ripple) up counter | `tff` |
| [`sync_counter`](rtl/sequential/sync_counter.v) | N-bit synchronous up counter | `tff` |
| [`updown_counter`](rtl/sequential/updown_counter.v) | N-bit synchronous up/down counter | `tff` |

### Finite state machines and sequential circuits: [`rtl/fsm/`](rtl/fsm)

| Module | Description | Uses |
|---|---|---|
| [`seq_circuit_dff`](rtl/fsm/seq_circuit_dff.v) | Two D flip-flops built from next-state equations (A⁺ = xy' + xB, B⁺ = xA + xB', z = A) | `dff` |
| [`seq_circuit_tff`](rtl/fsm/seq_circuit_tff.v) | Two T flip-flops with T_A = A + B, T_B = A' + B; 3-state cycle plus a transient state | `tff` |
| [`fsm_moore`](rtl/fsm/fsm_moore.v) | 4-state Moore machine; the output depends on the state only | |
| [`fsm_mealy`](rtl/fsm/fsm_mealy.v) | The same transitions as a Mealy machine; the output also depends on the input | |
| [`ones_zeros_detector`](rtl/fsm/ones_zeros_detector.v) | Asserts `out` after two 1s and two 0s have been entered as (possibly multi-cycle) pulses | |

The testbenches are in [`tb/`](tb), mirroring the `rtl/` layout:
`basic_gates_tb`, `compound_tb`, `mux_tb`, `demux_tb`, `decoder_tb`,
`priority_encoder_tb`, `adder_tb`, `flipflops_tb`, `universal_shift_reg_tb`,
`serial_adder_tb`, `counters_tb`, `seq_circuit_tb`, `fsm_tb` and
`ones_zeros_detector_tb`. Small modules are tested exhaustively; larger ones
with directed cases plus pseudo-random vectors (fixed seed, so runs are
reproducible) compared against a reference model.

## Conventions

- **File = module.** One module per file, named after the file, wrapped in an
  include guard. Testbenches may also hold small helper modules.
- **Clocks and resets.** All sequential modules are positive-edge triggered with an
  asynchronous **active-low** reset (`rst_n`), except `ones_zeros_detector`,
  which uses an active-high `reset` as its specification asks.
- **Bit order.** `in[0]` is the LSB. Select and address inputs are binary:
  `mux4to1` outputs `in[sel]`, and `decoder2to4` with `in = 2'b01` drives
  `out[1]`. Minterm indices in the `compound_*` modules take A as the MSB.
- **Style.** Modules start with a header comment giving the behavior or truth
  table. The early blocks (gates, mux, demux, decoder, encoder, adders) are
  deliberately gate-level or hierarchical, because building bigger blocks from
  smaller ones was the point of the exercises. The sequential blocks use
  non-blocking assignments (`<=`) in clocked processes.

## Notes and limitations

- `ripple_counter` is asynchronous: the stages switch one after another, so
  `count` is only valid after the ripple settles. In zero-delay simulation this
  is not visible; add gate delays to see it.
- `sr_latch` and `srff` drive `x` on the forbidden input S = R = 1.
- All modules synthesize in Yosys. `sr_latch` becomes a latch (use `srff` on an
  FPGA) and `ripple_counter` uses derived clocks (use `sync_counter` on an
  FPGA). Nothing has been run through a vendor tool or on real hardware.
- For design rationale, `wire` vs `reg`, `always` blocks, reset and clocking,
  and how to put these on an FPGA, see [docs/design-notes.md](docs/design-notes.md).

## Where the exercises come from

The modules follow the *Practice Problems for Verilog* sheet from the VLSI
Design course (Prof. Abhishek Srivastava, CVEST, IIIT Hyderabad), included as
[docs/Practice_problems_Verilog.pdf](docs/Practice_problems_Verilog.pdf). The
original assignment report is in [docs/assignment/](docs/assignment).

| Exercise | Topic | Modules |
|---|---|---|
| 1 | Logic gates | `basic_gates` |
| 2 | Compound circuits with universal gates | `compound_1` … `compound_5` |
| 3 | MUX, DEMUX, decoder, priority encoder | `mux*`, `demux*`, `decoder*`, `priority_encoder_8to3` |
| 4 | Adders | `full_adder`, `ripple_adder_*`, `cla_*` |
| 5 | Flip-flops | `dff`, `jkff`, `srff` / `sr_latch`, `tff` |
| 6 | 4-bit universal shift register | `universal_shift_reg` |
| 7 | 3-bit serial adder | `serial_adder` |
| 8 | Counters | `sync_counter`, `updown_counter`, `ripple_counter` |
| 9 | Sequential circuits | `seq_circuit_dff`, `seq_circuit_tff` |
| 10 | Moore and Mealy FSMs | `fsm_moore`, `fsm_mealy` |
| 11 | Two 1s and two 0s detector | `ones_zeros_detector` |
