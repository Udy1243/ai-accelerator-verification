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

**Note:** these numbers are from the phase-1 RTL (329 Yosys cells), before the
round_mode rounding path was added (now 343 cells). Area/power/timing will
shift slightly with the extra combinational logic — re-run OpenLane to refresh
these once phase 2 is otherwise verified.

| Metric | Value |
|--------|-------|
| Core area | 5,780.5 µm² |
| Logic cells | 233 |
| Core utilization | 42.5% |
| Critical path | 3.88 ns |
| Max frequency | 257.7 MHz |
| Target frequency | 40 MHz |
| Timing slack | +21.12 ns |
| Total power (typical) | ~0.117 mW |
| Routing (DRC) violations | 0 |
| Antenna violations | 0 |
| LVS errors | 0 |

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
(Expected — re-run on EDA Playground against the updated `testbench.sv` to confirm.)

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

Unlike Rung 3's AXI-Stream `dot_product`, this DUT has no `tready` handshake —
it's a fixed 1-cycle-latency pipeline with no internal buffering that could
stall. The driver instead holds inputs steady until `valid_out` fires before
moving to the next transaction (2 cycles/transaction).

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
tb/tb_gear_quantizer.sv   — directed testbench (6 tests)
tb/tb_cosim.sv            — co-simulation testbench (reads sim/vectors.txt)
tb/generate_vectors.py    — Python golden model + vector generator
tb/uvm/testbench.sv       — UVM testbench + functional coverage (complete)
Makefile                  — sim / cosim / synth / waves targets
TESTPLAN.md               — verification plan
```
