# Design notes

Why the code in this repo is written the way it is: synthesizability, FPGA use,
`wire` vs `reg`, `always` blocks, parameters, ports, reset and clocking, plus
tips and gotchas. It is meant as a study guide for the code as well as a record
of the decisions.

Contents:
[1. Quick answers](#1-quick-answers) ·
[2. What was checked](#2-what-was-and-was-not-checked) ·
[3. Synthesis results](#3-synthesis-results) ·
[4. wire vs reg](#4-wire-vs-reg-and-the-other-types) ·
[5. always blocks](#5-always-blocks) ·
[6. parameter vs localparam](#6-parameter-vs-localparam) ·
[7. Ports](#7-ports) ·
[8. Reset and clocking](#8-reset-and-clocking) ·
[9. Using this on an FPGA](#9-using-this-on-an-fpga) ·
[10. Choices per module](#10-design-choices-per-module-family) ·
[11. Simulation vs hardware](#11-simulation-vs-hardware) ·
[12. Tips and gotchas](#12-tips-and-gotchas) ·
[13. Re-running the synthesis check](#13-re-running-the-synthesis-check)

---

## 1. Quick answers

| Question | Answer |
|---|---|
| Are all modules synthesizable? | Yes, every file in `rtl/` goes through Yosys without errors. One (`sr_latch`) synthesizes to a **latch**, which is legal but usually avoided on FPGAs. One (`ripple_counter`) uses **derived clocks**, which synthesize but are poor FPGA practice. See [section 3](#3-synthesis-results). |
| Are the testbenches synthesizable? | No, and they are not meant to be. They use `$display`, `$random`, `#` delays and `initial` blocks, which exist only in simulation. |
| Can I flash them onto an FPGA? | Not directly. These are building blocks, not a complete design. You need a small top-level module that connects them to the board's clock, buttons and LEDs, plus a pin-constraints file for your board. [Section 9](#9-using-this-on-an-fpga) has a tested example top-level and the full list of things to handle. |
| Are `wire` and `reg` used correctly? | Yes. Every `reg` is assigned inside an `always` block and every `wire` is driven by an `assign`, a gate or a submodule output. [Section 4](#4-wire-vs-reg-and-the-other-types) explains the rule. |
| Are the `always` blocks clear? | They follow three fixed patterns: clocked with non-blocking `<=`, combinational with `@(*)` and blocking `=`, and one deliberate latch. [Section 5](#5-always-blocks). |
| Are the `localparam`s appropriate? | Yes: state codes in the two FSMs and the saturation limit in `ones_zeros_detector`. Everything meant to be changed by the user is a `parameter` instead. [Section 6](#6-parameter-vs-localparam). |
| Are the ports appropriate? | Yes. There are a few unused ports on purpose, all listed in [section 7](#7-ports). |

---

## 2. What was and was not checked

**Checked**

- **Simulation** (Icarus Verilog): 14 self-checking testbenches, plus a compile of
  every file on its own with all warnings treated as errors.
  Run `scripts/run_tests.sh`.
- **Synthesis** (Yosys, generic flow): all 37 modules synthesized as the top
  level, followed by structural checks for combinational loops, multiple drivers
  and undriven signals. All passed; the one latch and the derived clocks are
  described below.
- **Example top-level** ([section 9](#9-using-this-on-an-fpga)): compiles without
  warnings and synthesizes to 28 flip-flops with no latches.

**Not checked**

- **No vendor tool** (Vivado, Quartus, Libero) and **no real FPGA**. Synthesizing
  in Yosys is good evidence the code is fine, but it is not the same as a clean
  build and timing closure in the tool for your board.
- **Timing.** Everything was simulated with zero delay. Maximum clock speed,
  setup/hold and glitches were not analysed.
- **Technology mapping.** The Yosys run used its generic flow, so there are no
  LUT counts or utilisation numbers.
- **Include paths in vendor tools.** Files `include` each other by paths relative
  to the repository root (for example `` `include "rtl/sequential/dff.v" ``). That
  works with Icarus and Yosys when run from the root. Vendor tools may need the
  repo root added as an include directory. See section 9.

---

## 3. Synthesis results

What each group turns into. "DFF" means a flip-flop with an asynchronous reset.

| Modules | Becomes | Notes |
|---|---|---|
| `basic_gates`, `compound_1…5`, `mux*`, `demux*`, `decoder*`, `priority_encoder_8to3`, `full_adder`, `ripple_adder_*`, `cla_*` | Pure combinational logic | No flip-flops, no latches. Gate primitives (`and`, `nand`, …) and `assign` are both fully synthesizable. |
| `dff` | 1 DFF | |
| `tff`, `jkff`, `srff` | 1 DFF with a clock-enable | The tool folds "toggle only when `t = 1`" into the flip-flop's enable pin. |
| `universal_shift_reg` | N DFFs | One per bit. The 4:1 mux in front of each is ordinary logic. |
| `serial_adder` | 2N + 1 DFFs | Two shift registers plus one carry flip-flop. |
| `sync_counter`, `updown_counter` | N DFFs with enable | |
| `ripple_counter` | N DFFs, but stages 1…N-1 are **clocked by the previous stage's output** | See "derived clocks" below. |
| `fsm_moore`, `fsm_mealy` | 4 DFFs | Written with a 2-bit state, but Yosys re-encoded it as **one-hot** (4 flip-flops). Synthesis tools do this on their own, so there is no point hand-optimizing state codes. |
| `ones_zeros_detector` | 6 DFFs | 2 for edge detection plus two 2-bit counters. |
| `seq_circuit_dff`, `seq_circuit_tff` | 2 DFFs | |
| `sr_latch` | **1 latch** | See below. |

**The latch (`sr_latch`).** An S-R latch is level-sensitive and has memory
without a clock, so it is a latch by definition. That is the point of the
module, and it is the only latch in the repo. On an FPGA, latches are best
avoided: the fabric is built around flip-flops, timing analysis of latches is
harder, and many vendor flows warn about them. Use `srff` (the clocked version)
in real designs. Also note that `q = 1'bx` for S = R = 1 is a simulation-only
idea. Hardware has no "unknown" value, so synthesis treats it as "don't care".

**Derived clocks (`ripple_counter`).** In a ripple counter each stage's clock is
the previous stage's output (`~count[i-1]`). That synthesizes, and Yosys maps
those flip-flops as negative-edge clocked, but on an FPGA it creates clocks that
are not on the dedicated clock network. The timing tools then have a hard time,
and the count shows glitches while the ripple settles. It is fine for learning
how a ripple counter works. For real designs use `sync_counter`, which gives
the same result with one shared clock.

---

## 4. `wire` vs `reg` (and the other types)

This is the most confusing part of Verilog, mostly because of the name `reg`.

### The rule

|  | `wire` | `reg` |
|---|---|---|
| What it is | A **connection**. Its value is whatever is currently driving it. | A **variable** that remembers the last value assigned to it. |
| Can be driven by | `assign`, a gate primitive, or a submodule's output port | Only assignments inside an `always` (or `initial`) block |
| Can be assigned inside `always`? | No | Yes, and it is the only thing that can |

The common mistake: **`reg` does not mean "a hardware register".** It only means
"something an `always` block assigns to". What hardware you get depends on the
`always` block, not on the word `reg`:

| `always` block looks like | Hardware | Example in this repo |
|---|---|---|
| `always @(posedge clk ...)` | A **flip-flop** | `q` in `dff`, `state` in `fsm_moore` |
| `always @(*)` that assigns the signal on every path | Plain **combinational logic**, no storage | `next_state` in `fsm_moore` (it is a `reg` but has no flip-flop) |
| `always @(*)` that skips a path | A **latch** (usually a bug) | `q` in `sr_latch` (here it is intended) |

So `next_state` and `state` are both declared `reg`, yet one is wires and gates,
and the other is flip-flops.

### How to decide what to declare

1. Is it assigned in an `always` block? Use **`reg`**.
2. Is it driven by `assign`, a gate, or a submodule port? Use **`wire`** (or just
   an `output` / `input`, which are wires by default).
3. Inputs are always wires. Outputs are `output` (a wire) unless an `always`
   block assigns them, in which case `output reg`.

This repo applies it like this:

- `dff`, `tff`, `jkff`, `srff`: `output reg q`, because an `always` block sets
  it; `output q_n`, because `assign q_n = ~q`.
- `fsm_moore`, `fsm_mealy`: `reg [1:0] state, next_state` for the two `always`
  blocks; `output y` is a wire driven by `assign`.
- `ones_zeros_detector`: `reg` for `one_q`, `zero_q`, `ones`, `zeros` (all set in
  one clocked block); `wire` for `one_pulse`, `zero_pulse`; `out` from `assign`.
- Everything built from gates or submodules (`mux*`, adders, decoders, …) uses
  only `wire` and ports.

### Other declarations you will see

| Keyword | Meaning | Where |
|---|---|---|
| `integer` | A 32-bit signed variable for loops and counters in **simulation**. Not used in `rtl/`. | Testbenches |
| `genvar` | A loop index for `generate` loops. It exists only while the design is built, never in hardware. | `ripple_adder_*`, `cla_16bit`, counters, `universal_shift_reg` |
| `parameter` / `localparam` | Compile-time constants. See [section 6](#6-parameter-vs-localparam). | |
| `logic` | SystemVerilog's single type that replaces both `wire` and `reg`, so this whole discussion goes away. Not used here so the code runs with plain Verilog-2005 and `-g2005`. | |

### Two related traps

- **Implicit wires.** If you mistype a name in a port connection, Verilog
  silently creates a new 1-bit wire instead of reporting an error. Compiling
  with `-Wall` (as `scripts/run_tests.sh` does) catches this. Adding
  `` `default_nettype none `` at the top of a file makes it an error in every tool.
- **One driver per signal.** A `reg` should be assigned in only one `always`
  block, and a `wire` should have only one source. Two drivers fight in
  simulation and fail in synthesis.

---

## 5. `always` blocks

There are only three kinds in the repo, and each has a fixed shape.

### A. Clocked logic: flip-flops

```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        q <= 1'b0;          // reset has priority
    else
        q <= d;
end
```

- Sensitivity list: the clock edge, plus the reset edge if the reset is
  asynchronous.
- Use **non-blocking** assignment (`<=`). A clock edge makes every flip-flop
  sample its inputs at the same instant, then all update together. `<=` models
  exactly that: all right-hand sides are read first, all left-hand sides are
  updated after.
- The `if (!rst_n)` branch comes first, so reset wins over everything else.

Used in: `dff`, `tff`, `jkff`, `srff`, the FSM state registers, and
`ones_zeros_detector`.

### B. Combinational logic

```verilog
always @(*) begin
    case (state)
        A:       next_state = x ? C : B;
        B:       next_state = x ? D : C;
        C:       next_state = x ? D : B;
        D:       next_state = x ? A : C;
        default: next_state = A;      // every path assigns next_state
    endcase
end
```

- `@(*)` means "re-run whenever anything I read changes". Never write the list
  by hand; forgetting a signal makes simulation and hardware disagree.
- Use **blocking** assignment (`=`). Statements run in order, like software,
  which is what combinational logic needs.
- **Assign the output on every path**, here with `default`. A path that does not
  assign it makes the tool keep the old value, and that is a latch.

Used in: the next-state logic of `fsm_moore` and `fsm_mealy`. Simple
combinational outputs (`y` in the FSMs, `out` in the detector) use `assign`
instead, which cannot create a latch by accident.

### C. The deliberate latch

`sr_latch` uses `always @(*)` with `if / else if` and **no final `else`**, so
`s = r = 0` holds the old value. That is the whole point of a latch. It uses
blocking `=`, which is the convention for latch and combinational code.

### Rules this code follows

| Rule | Why |
|---|---|
| Clocked blocks use only `<=`; combinational blocks use only `=` | Mixing them in one block causes race conditions. The original `TFF` used `=` in a clocked block, which is why it was rewritten. |
| One `always` block per output signal | Two blocks driving the same `reg` is a multiple-driver error. |
| FSMs are split into **state register / next-state logic / output logic** | The standard "three-part" style. Each part is small and can be read on its own. |
| Every `case` has a `default` | Prevents accidental latches and handles unused state codes. |
| `begin … end` on every block, even one-liners | Avoids the classic "added a second line and it is not in the `if`" bug. |

---

## 6. `parameter` vs `localparam`

Both are compile-time constants. The difference is who may change them:

| | Can be overridden from outside? | Use for |
|---|---|---|
| `parameter` | Yes, `module #(.N(8))` at instantiation | Knobs for users of the module |
| `localparam` | No, private to the module | Constants the module depends on to work |

| Where | Kind | Why |
|---|---|---|
| `N` in `universal_shift_reg`, `serial_adder`, `ripple_counter`, `sync_counter`, `updown_counter` | `parameter` | The width is meant to be chosen by whoever uses the module. |
| `RESET_VAL` in `tff`, `RESET_STATE` in `seq_circuit_tff` | `parameter` | Lets one design start in different states, for example 00 or 11. |
| `A, B, C, D` in `fsm_moore`, `fsm_mealy` | `localparam` | They are the state codes, and the `case` logic depends on exactly these values. Letting a user override them could silently break the machine. |
| `TARGET` in `ones_zeros_detector` | `localparam` | The count that both counters saturate at. A named constant is clearer than repeating `2'd2` four times. |

Why not `` `define ``? A `localparam` is scoped to its module and typed (`[1:0]`
here), so it cannot clash with names in other files. `` `define `` is a global
text substitution. The repo uses it only for the include guards.

A fair criticism: single-letter state names `A…D` are terse. They are kept
because they match the state diagrams in the exercise sheet. In a larger design
use descriptive names such as `S_IDLE`, `S_RUN`.

---

## 7. Ports

Conventions:

- **ANSI style**, with the direction and type in the module header
  (`input clk`, `output reg q`), so each port is declared exactly once.
- **Named connections** (`.clk(clk), .d(d)`) everywhere, never positional, so
  reordering ports cannot silently swap signals.
- **Names:** `clk`, `rst_n` (the `_n` suffix means active low), `en`, `d`, `q`,
  `q_n`. Vectors are `[N-1:0]` with bit 0 the LSB.
- **Unused outputs** are connected as `.q_n()` to say "unused on purpose".

Ports that are unused or look redundant, and why:

| Port | Reason |
|---|---|
| `compound_4` input `c` | The function `F(A,B,C,D)` happens not to depend on C. The port is kept so the module has the full interface from the exercise. Synthesis will report an unused input. |
| `basic_gates` input `b` | The NOT gate only uses `a`. |
| `cla_4bit` outputs `pg`, `gg` | Needed by `cla_16bit`; unused when `cla_4bit` is used alone. |
| `seq_circuit_dff` outputs `a`, `b`, `z` | `z` equals `a`. All three are exposed so the state can be observed. |
| `ones_zeros_detector` reset is active **high** (`reset`) while everything else is active low (`rst_n`) | The exercise specification asks for an active-high reset. |

---

## 8. Reset and clocking

**Asynchronous active-low reset everywhere.** Every flip-flop uses
`always @(posedge clk or negedge rst_n)` and the course convention.

| | Asynchronous reset | Synchronous reset |
|---|---|---|
| Sensitivity list | `posedge clk or negedge rst_n` | `posedge clk` |
| Resets when | Immediately when asserted | At the next clock edge |
| Pros | Works without a clock; maps to the flip-flop's reset pin | Fully synchronous design; easier timing analysis |
| Cons | **Releasing** reset near a clock edge can put flip-flops in different states | Needs a running clock; costs a bit of logic |

Common practice, and what the example in section 9 does: **assert reset
asynchronously, release it synchronously** with a two-flip-flop reset
synchronizer. Note that many Xilinx guidelines recommend synchronous resets
for FPGAs, so check your vendor's advice.

**Use clock enables, not divided clocks.** To make something happen slowly
(for example blinking an LED from a 12 MHz clock), do not create a slower clock
from a counter. Keep the single board clock and generate a one-cycle `tick` to
use as an enable (`sync_counter` has an `en` input for this). Derived and gated
clocks cause timing and glitch problems.

**Inputs from outside the chip.** Anything not generated by your own clock
(buttons, switches, another board) is asynchronous. Pass it through a
two-flip-flop synchronizer before it reaches your logic, and debounce
mechanical buttons. `ones_zeros_detector` assumes its inputs are already
synchronous, as its specification says, so it needs a synchronizer plus a
debouncer in front of real push buttons.

---

## 9. Using this on an FPGA

The modules are **building blocks**. To put one on a board you need a small
wrapper (the *top-level module*) that connects it to the board's real pins,
and a constraints file that says which physical pin is which.

### What you need

1. **A top-level module** that takes the board clock, a reset button, and
   whatever LEDs and switches you want, and instantiates the library modules.
2. **A constraints file** mapping top-level port names to pins. The format
   depends on the toolchain: `.pcf` (nextpnr, iCE40), `.lpf` (ECP5),
   `.xdc` (Vivado), `.qsf` (Quartus). The pin numbers come from your board's
   documentation.
3. **A toolchain** for your FPGA family: Vivado (Xilinx/AMD), Quartus (Intel),
   Libero (Microchip), or the open-source Yosys + nextpnr for iCE40, ECP5 and
   some others.

I do not know which board you have. If you tell me, I can write the constraints
file and a matching top-level.

### An example top-level (tested)

This blinks the 4 LEDs as a binary counter at a human-visible speed. It
compiles without warnings in Icarus Verilog and synthesizes in Yosys to 28
flip-flops with no latches.

```verilog
`include "rtl/sequential/sync_counter.v"

`timescale 1ns / 1ps

module blinky_top (
    input        clk,       // board clock, e.g. 12 MHz
    input        btn_n,     // active-low push button, used as reset
    output [3:0] led
);

    // 1. The button is asynchronous. Assert reset immediately, but release it
    //    in step with the clock (two-flop reset synchronizer).
    reg [1:0] rst_sync;
    always @(posedge clk or negedge btn_n) begin
        if (!btn_n) rst_sync <= 2'b00;
        else        rst_sync <= {rst_sync[0], 1'b1};
    end
    wire rst_n = rst_sync[1];

    // 2. Slow things down with a clock ENABLE (one pulse every 2^22 clocks),
    //    not with a divided clock.
    reg [21:0] div;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) div <= 22'd0;
        else        div <= div + 22'd1;
    end
    wire tick = &div;

    // 3. The library module, running on the board clock.
    sync_counter #(.N(4)) counter (.clk(clk), .rst_n(rst_n), .en(tick), .count(led));

endmodule
```

Keep the top-level in your own file or project, not in `rtl/`, and run the
tools from the repository root so the root-relative `include` paths resolve.

### Things that behave differently on real hardware

| Topic | What to know |
|---|---|
| **Speed** | A board clock is 12 to 100 MHz. At that rate a plain counter changes far faster than an eye can see, so use a clock enable as above. |
| **Buttons** | Mechanical buttons bounce for a few milliseconds and are asynchronous. Synchronize and debounce them. |
| **Power-up state** | FPGA flip-flops start at a known value (usually 0) after configuration, but do not rely on it. Use a reset. |
| **`x` and `z`** | They do not exist in hardware. `1'bx` in `srff` or `sr_latch` becomes "don't care" and the tool picks 0 or 1. |
| **`#` delays, `$display`, `initial`** | Ignored or unsupported by synthesis. They are for testbenches only. |
| **Latches** | Avoid. Use `srff` instead of `sr_latch`. |
| **Ripple counter** | Avoid on an FPGA. Use `sync_counter`. |
| **Mealy output** | `fsm_mealy`'s `y` depends combinationally on the input `x`, so it can glitch when `x` changes. Register it, or sample it only at the clock edge, if something downstream is sensitive. |
| **Include paths** | The files use root-relative `include` paths. In a vendor tool, add the repository root to the include search path. If the tool complains about modules defined twice, add only your top-level file to the project and let the `include`s pull in the rest. This was **not tested** in a vendor tool. |

---

## 10. Design choices per module family

| Family | Choice | Reason |
|---|---|---|
| Gates, compound circuits | Gate primitives (`nand` only for `compound_*`) | The exercise asks for logic gates and universal gates. `compound_*` use NAND-NAND two-level logic. Inverters are NANDs with tied inputs. |
| Mux, demux, decoder | Built hierarchically from the smaller version (2→4→8) | The exercise asks for it, and it shows how large blocks are composed. Sizes are separate modules, not one parameterized module. |
| Priority encoder | Hand-minimised gate equations plus a `valid` output | Without `valid`, "input 0 is set" and "nothing is set" both give `000`. |
| Full adder | Two half adders plus an OR, sharing `a ^ b` | Only 2-input gates, and the shared term saves a gate. |
| Ripple adders | Chain of `full_adder` | The textbook structure. |
| CLA | `cla_lookahead_4` computes four carries at once from propagate/generate; used for bits inside `cla_4bit` and for blocks in `cla_16bit` | A real two-level carry-lookahead, and one lookahead unit instead of two copies of the equations. |
| Flip-flops | Positive-edge, async active-low reset, `q_n = ~q` by `assign` | One consistent interface for everything built on top. |
| S-R | Both `sr_latch` and clocked `srff` | The original "R-S flip-flop" was really a latch; the clocked version is what the term usually means. |
| Shift register | One `mux4to1` + one `dff` per bit | Shows the classic structure. Shift inputs are built with concatenation (`{sr_in, q[N-1:1]}`). |
| Serial adder | Two shift registers, one `full_adder`, one carry `dff`; `load` and `shift` controls | One bit per clock. The carry is held by an enable-style `d` input, not a gated clock. |
| Counters | Built from `tff` | Matches the exercise. Each stage's toggle enable is one wide AND (`&count[i-1:0]`), not a chain. |
| Up/down counter | `up` has priority over `down` | A defined behaviour for the both-high case. |
| FSMs | Three-part style: state register / next-state `always @(*)` / output `assign` | Standard and readable. Moore and Mealy share transitions so the only difference is the output. |
| `ones_zeros_detector` | Rising-edge detection plus two saturating counters | The spec says a held-high pulse counts once, so counting edges (not cycles) is required. |
| Testbenches | Self-checking; exhaustive where small, fixed-seed random where large | They print `PASS`/`FAIL` and the runner exits non-zero on failure, so they can be re-run after every change. |

---

## 11. Simulation vs hardware

Simulation lets you write things that hardware cannot do:

| Only in simulation | Hardware equivalent |
|---|---|
| `#5` delays | Real gate and wire delay, which you do not control |
| `initial` blocks | FPGA initial values only, via the configuration |
| `$display`, `$monitor`, `$dumpvars`, `$random`, `$finish` | Nothing |
| `x` (unknown) and `z` (high impedance) | Only 0 and 1 (and tri-state pads) |
| Zero-delay evaluation | Real propagation time and glitches |

Because simulation is more forgiving, passing tests do not prove a design is
synthesizable. Run both, and run synthesis early.

**Race conditions.** If two blocks update and read the same signal at the same
clock edge using blocking `=`, the result depends on the simulator's internal
ordering. The original `TFF` had this problem; it happened to work in Icarus
but is not guaranteed anywhere. Non-blocking `<=` in clocked blocks removes the
problem entirely. A testbench cannot reliably detect such a race, so follow the
rule instead of relying on tests.

**Testbench input timing.** The testbenches change inputs on the **falling**
clock edge and check just after the **rising** edge. This keeps stimulus away
from the active edge and avoids races between the testbench and the design.

---

## 12. Tips and gotchas

1. **Compile with warnings on** (`iverilog -Wall`). It catches implicit wires,
   missing connections and timescale mismatches.
2. **`reg` is not a register.** Look at the `always` block to know what hardware
   you get.
3. **Clocked: `<=`. Combinational: `=`.** Never mix them in one block.
4. **Assign every output on every path** of a combinational block, or you get a
   latch.
5. **One driver per signal.**
6. **Avoid gated clocks and divided clocks.** Use clock enables.
7. **Synchronize anything that comes from outside your clock domain.**
8. **Release reset synchronously** (two flip-flops).
9. **Avoid latches** in FPGA designs; `srff` over `sr_latch`.
10. **Use `parameter` for widths** so one module serves many sizes, and
    `localparam` for constants the module depends on.
11. **Use named port connections**, never positional ones.
12. **Check widths.** Verilog silently truncates or extends. For example
    `a + b` assigned to a 4-bit sum drops the carry, which is why adders use
    `{cout, sum}`.
13. **Beware of x-propagation.** An uninitialised `reg` is `x` in simulation.
    Reset everything you read, and test with `===` / `!==` (which compare `x`
    exactly) rather than `==` / `!=` (which return `x`, not 0 or 1, when an
    operand is `x`).
14. **Do not hand-pick FSM encodings** for speed. Tools re-encode them anyway.
15. **Put `include` guards on every file** that other files include, or a module
    pulled in twice is a redefinition error. Every file in `rtl/` has one.
16. **Keep waveforms and build output out of git.** `build/`, `*.vcd` and
    `*.vvp` are in `.gitignore`.
17. **Look at synthesis warnings.** "Latch inferred", "multiple drivers" and
    "unused input" are the ones that matter most.
18. **Next steps for learning:** try SystemVerilog (`logic`, `always_ff`,
    `always_comb`), which makes the `wire`/`reg` and latch pitfalls errors
    instead of conventions, and run a real FPGA flow end to end on the blinky
    example.

---

## 13. Re-running the synthesis check

Install Yosys (for example `pip install yowasp-yosys` into a virtual
environment, or the OSS CAD Suite). From the repository root, for any module:

```sh
yosys -p "read_verilog -I . rtl/fsm/fsm_moore.v; \
          hierarchy -check -top fsm_moore; proc; check; \
          synth -flatten -top fsm_moore; check -assert; stat"
```

- `-I .` lets the root-relative `include` lines resolve.
- `proc` converts `always` blocks to logic; a "Latch inferred" warning appears
  here if a combinational block is incomplete.
- `check -assert` fails on combinational loops, multiple drivers and undriven
  signals.
- `stat` prints the cells used, including the type of every flip-flop.

For an FPGA-specific mapping, replace `synth` with `synth_ice40`,
`synth_ecp5` or `synth_xilinx`.
