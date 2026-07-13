# Rung 4 — GEAR Outlier-Aware INT4 Quantizer

GEAR-inspired outlier-aware quantizer in SystemVerilog with directed testbench,
Python co-simulation (1000 random vectors), and Yosys synthesis.

## What it does

Instead of quantizing all values uniformly, the module detects outliers
(values whose absolute value exceeds a configurable threshold) and routes
them to a full-precision INT8 sideband path. Non-outlier values are
quantized to INT4 by scaling down with a fixed-point fraction and clipping.

```
if abs(data_in) > threshold:
    is_outlier = 1, sideband_out = data_in, int4_out = 0
else:
    is_outlier = 0, sideband_out = 0
    product = data_in × scale                    # scale is Q0.4: scale/16, so 0 to 15/16
    int4_out = clip(round_or_truncate(product >> 4, round_mode), −8, 7)
```

`scale` is interpreted as a fixed-point fraction (`scale / 2^INT4_WIDTH`), so it
can only attenuate `data_in`, never amplify it — matching how real quantizers
scale a wide dynamic range down into a narrow one. `round_mode` selects
between truncating the shift (`0`) and rounding to nearest based on the MSB of
the 4 dropped bits (`1`); clipping still applies after rounding, since a
round-up can push a near-max value one step past `INT4_MAX`.

1-cycle pipeline latency. `valid_out` follows `valid_in` by one clock.

## Port List

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk` | in | 1 | Clock |
| `rst_n` | in | 1 | Active-low reset |
| `valid_in` | in | 1 | Input data valid |
| `data_in` | in | 8 (signed) | Input value |
| `threshold` | in | 8 | Outlier detection threshold |
| `scale` | in | 4 | Scale factor for INT4 quantization |
| `round_mode` | in | 1 | 0=truncate, 1=round-to-nearest (implemented) |
| `valid_out` | out | 1 | Output valid |
| `is_outlier` | out | 1 | 1 if input exceeded threshold |
| `int4_out` | out | 4 (signed) | Quantized INT4 result (0 if outlier) |
| `sideband_out` | out | 8 (signed) | Original INT8 value (0 if not outlier) |

## Results

### Directed Tests (iverilog)
```
PASS [Test 1: Normal quantization]
PASS [Test 2: Positive outlier]
PASS [Test 3: Negative outlier]
PASS [Test 4: Boundary (abs==threshold)]
PASS [Test 5: Scale zero]
PASS [Test 6: Negative normal, truncate]
PASS [Test 7a: round_mode=0 truncates]
PASS [Test 7b: round_mode=1 rounds up (same inputs as 7a)]
PASS [Test 8a: round_mode=0, at max, no overflow]
PASS [Test 8b: round_mode=1 overflows max, clip saturates back to 7]
```
10/10 passing. Tests 7a/7b and 8a/8b directly prove `round_mode` changes
behavior on identical inputs — 7a/7b shows a genuine round-up, 8a/8b shows
clipping still saturates correctly when rounding pushes a value past `INT4_MAX`.

### Python Co-Simulation
```
Co-sim done: 1000/1000 passed
```
1000 random vectors (data_in ∈ [−128,127], threshold ∈ [0,100], scale ∈ [0,15],
round_mode ∈ {0,1}) — 0 failures. The golden model uses Python's `//` and `%`,
which are floor-based and mirror SystemVerilog's arithmetic right-shift exactly
(including for negative products), so no manual two's-complement handling is
needed on the Python side.

### Yosys Synthesis
```
Number of cells: 343
  Flip-flops:    14   (valid_out + is_outlier + int4_out[4] + sideband_out[8])
  $_XOR_:        56   (multiplier partial product tree)
  $_ANDNOT_:    114   (comparator, clip, and round-increment logic)
  $_MUX_:         6   (outlier routing mux)
```
Cell count rose from 329 → 343 (+14) after adding the shift/round-increment
path — flip-flop count is unchanged since the new logic is purely combinational.

### OpenLane SKY130 Results

| Metric | Phase 1 | Phase 2 (current) |
|--------|---------|--------------------|
| Core area | 5,780.5 µm² | 6,313.6 µm² |
| Logic cells | 233 | 253 |
| Core utilization | 42.5% | 43.0% |
| Critical path | 3.88 ns | 13.19 ns |
| Max frequency | 257.7 MHz | ~75.8 MHz |
| Target frequency | 40 MHz | 40 MHz |
| Timing slack | +21.12 ns | +11.81 ns |
| Total power (typical) | ~0.117 mW | ~0.136 mW |
| Routing (DRC) violations | 0 | 0 |
| Antenna violations | 0 | 0 |
| LVS errors | 0 | 0 |

Max frequency dropped from 257.7 MHz to ~75.8 MHz despite only +20 cells,
because the round-up increment (`rounded_res = shifted_res + round_incr`) is
a real adder inserted in series, directly in front of the (unchanged) clip
comparison logic. Unlike a mux, an adder's carry has to ripple sequentially
through every bit position before the top bit is known, so it adds real gate
delay proportional to width — the critical path (per the signoff STA report)
starts at `scale[3]` and runs through this carry chain into the clip logic.
Still comfortably meets the 40 MHz target (+11.81 ns slack). If higher
frequency were ever needed, the fix would be the same idea as Rung 3's FSM
DONE state — pipeline the shift/round and the clip/output into separate
cycles rather than one long combinational chain.

Floorplan uses relative sizing (`FP_CORE_UTIL=40`, `PL_TARGET_DENSITY=0.75`) so
the die scales to the design instead of reusing a fixed area — gear_quantizer
is roughly a quarter the cell count of the Rung 2 quantizer, so its core area
is correspondingly smaller rather than artificially matching it.

### UVM Testbench + Functional Coverage (EDA Playground)

Aldec Riviera-PRO 2025.04, UVM 1.2 — full env (interface, sequence item with
constraints, sequence, driver, monitor, scoreboard, coverage collector).

```
Results: 200 passed, 0 failed
UVM_ERROR : 0    UVM_FATAL : 0

Overall covergroup coverage: 100.00%
  cp_data_in_range: 100.00%
  cp_outlier:       100.00%
  cp_boundary:      100.00%
  cp_clip:          100.00%
  cp_scale:         100.00%
  cp_round_mode:    100.00%
  cp_round_applied: 100.00%
```

200 constrained-random transactions, including a `force_boundary` constraint
(~15% of transactions) that forces `abs(data_in) == threshold` — without it,
the exact-equality boundary case is a single point in a ~256×256 random space
and is very unlikely to get hit by chance.

`cp_round_mode` hitting 100% only confirms both `round_mode` values were
driven as stimulus, not that rounding actually changed anything — so
`cp_round_applied` was added on top of it. It tracks whether the round-up
increment actually fired (`round_mode=1` **and** the dropped nibble's MSB
set), with `applied`/`not_applied` bins. Both bins reliably hit within 200
transactions with no extra bias constraint needed — unlike the exact
boundary case, "rounding fires" is roughly a 1-in-4 event per non-outlier
transaction, not a single point in a huge space.

**Bug found and fixed during this run:** the first pass came back with
scoreboard 200/200 passed but `cp_round_applied` flat at 0.00% on both
bins. Root cause — the coverage collector's `write()` read
`item.round_applied` without ever calling `item.compute_expected()`
itself; that field was only populated as a side effect of the
scoreboard's `write()` call on the same shared item object (both are
independent subscribers of the same monitor analysis port, with no
guaranteed call order between them). Fixed by having the coverage
collector call `item.compute_expected()` unconditionally at the top of
its own `write()` — never rely on another analysis-port subscriber
having mutated the shared item first.

Unlike Rung 3's AXI-Stream `dot_product`, this DUT has no `tready` handshake —
it's a fixed 1-cycle-latency pipeline with no internal buffering that could
stall. The driver instead holds inputs steady until `valid_out` fires before
moving to the next transaction (2 cycles/transaction).

### SVA Assertions

Four immediate assertions run inside `gear_quantizer.sv` itself, checked every
cycle in `always @(posedge clk)` (iverilog runs immediate assertions natively;
no special tooling needed):

1. `int4_out` is zero whenever `is_outlier` is 1
2. `sideband_out` is zero whenever `is_outlier` is 0
3. `sideband_out` is non-zero whenever `is_outlier` is 1
4. `int4_out` stays within `[-8, 7]` on the normal (non-outlier) path

Property 3 originally compared `sideband_out !== data_in` directly, which
looked correct but always failed on real outlier tests. Root cause: `data_in`
is a combinational wire holding the *current* cycle's stimulus, while
`sideband_out` is a registered output holding *last* cycle's result — by the
time the assertion fires, `data_in` has already advanced to the next test's
value. `is_outlier` and `sideband_out`, by contrast, are assigned together in
the same `always_ff` block off the same `outlier_comp_res`, so they're
stage-matched — comparing `sideband_out` against `is_outlier` is safe;
comparing it against `data_in` is not. Property 3 now just checks
`sideband_out` is non-zero during an outlier, which is what a same-cycle,
same-stage assertion can actually verify; exact-value correctness is already
covered by the directed tests and the Python co-sim.

A fifth property — `valid_out` follows `valid_in` by exactly one clock —
needs the concurrent SVA `|=>`/`$past()` operators, which iverilog cannot
parse at all (confirmed: hard syntax error, not degraded support). Rather
than edit `gear_quantizer.sv` with syntax the primary toolchain can't build,
this property lives in a separate file, `rtl/gear_quantizer_sva.sv`, and is
attached with a `bind` statement instead of being pasted into the module:

```systemverilog
property p_valid_out_delay;
    @(posedge clk) disable iff (!rst_n)
    valid_out === $past(valid_in);
endproperty
assert property (p_valid_out_delay) else $error(...);
```

```systemverilog
bind gear_quantizer gear_quantizer_sva_checker sva_checker_inst (
    .clk(clk), .rst_n(rst_n), .valid_in(valid_in), .valid_out(valid_out)
);
```

`bind` attaches a checker module to every instance of `gear_quantizer` without
modifying its source — keeps `gear_quantizer.sv` iverilog-clean while still
letting a richer simulator exercise the concurrent property. `gear_quantizer_sva.sv`
is intentionally excluded from the Makefile's `sim` target.

**Run on EDA Playground (Aldec Riviera-PRO 2025.04):** compiled clean —
`Compile success 0 Errors 0 Warnings` — confirming the `property`/
`assert property`/`bind` syntax is valid SVA. Elaboration then failed with
`You do not have a valid license to simulate SystemVerilog assertion module`
— a licensing-tier restriction (Riviera-PRO's free EDA Playground tier
includes UVM + functional coverage but gates SVA elaboration behind a
separate paid license), not a defect in the property or the RTL. Checked all
other free tools on the account (GHDL, Verilator, Icarus Verilog) — none
support UVM, so there's no free combination that runs both UVM and
concurrent SVA together. Property 5 is written and parser-verified but
cannot currently be elaborated end-to-end on any available toolchain; it's
ready to run as-is if a licensed simulator becomes available.

## How to Run

```bash
# Directed tests
make sim

# Python co-simulation (generates 1000 vectors, runs SV testbench)
make cosim

# Yosys synthesis stats
make synth

# Open waveforms
make waves

# OpenLane SKY130 synthesis (from ~/OpenLane, requires Docker)
cd ~/OpenLane && make mount
# inside the container:
./flow.tcl -design /home/ugunt/projects/ai-accelerator-verification/rung4-gear-quantizer/openlane -overwrite
```

## Design Notes

- `abs(-128) = 128` fits in unsigned 8-bit — `abs_data_in` declared without `signed`
- Multiply uses `$signed({1'b0, scale})` to zero-extend scale before signed multiply
- Intermediate multiply result is 12-bit signed to hold worst case: `−128 × 15 = −1920`
- `valid_out <= valid_in` is unconditional in the `else` branch so it clears when input drops
- `scale` is fixed-point (`scale / 2^INT4_WIDTH`), not a plain integer multiplier — an
  arithmetic right-shift (`>>>`) by `INT4_WIDTH` bits recovers the integer part, and the
  MSB of the shifted-out nibble (`mult_res[INT4_WIDTH-1]`) is the round bit
- The round-up increment (`round_incr`) is a dedicated signed 2-bit register, added to
  `shifted_res` explicitly as signed — mirrors the earlier signed×unsigned multiply
  lesson, though in this specific case (matching widths, non-negative increment) an
  unsigned add would not actually have corrupted the result
- Clipping runs on `rounded_res`, after the round increment — a value already at
  `INT4_MAX` before rounding can be pushed one over and must still saturate correctly

## Files

```
rtl/gear_quantizer.sv     — RTL
rtl/gear_quantizer_sva.sv — concurrent SVA (bind-attached; EDA Playground only, not in local sim)
tb/tb_gear_quantizer.sv   — directed testbench (10 tests)
tb/tb_cosim.sv            — co-simulation testbench (reads sim/vectors.txt)
tb/generate_vectors.py    — Python golden model + vector generator
tb/uvm/testbench.sv       — UVM testbench + functional coverage (complete)
Makefile                  — sim / cosim / synth / waves targets
TESTPLAN.md               — verification plan
```
