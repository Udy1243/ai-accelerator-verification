# Rung 4 — GEAR Outlier-Aware INT4 Quantizer

GEAR-inspired outlier-aware quantizer in SystemVerilog with directed testbench,
Python co-simulation (1000 random vectors), and Yosys synthesis.

## What it does

Instead of quantizing all values uniformly, the module detects outliers
(values whose absolute value exceeds a configurable threshold) and routes
them to a full-precision INT8 sideband path. Non-outlier values are
quantized to INT4 by multiplying by a 4-bit scale factor and clipping.

```
if abs(data_in) > threshold:
    is_outlier = 1, sideband_out = data_in, int4_out = 0
else:
    is_outlier = 0, int4_out = clip(data_in × scale, −8, 7), sideband_out = 0
```

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
| `round_mode` | in | 1 | 0=truncate, 1=round-to-nearest (phase 2) |
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
PASS [Test 6: Negative normal]
```
6/6 passing.

### Python Co-Simulation
```
Co-sim done: 1000/1000 passed
```
1000 random vectors (data_in ∈ [−128,127], threshold ∈ [0,100], scale ∈ [0,15]) — 0 failures.

### Yosys Synthesis
```
Number of cells: 329
  Flip-flops:    14   (valid_out + is_outlier + int4_out[4] + sideband_out[8])
  $_XOR_:        56   (multiplier partial product tree)
  $_ANDNOT_:    120   (comparator and clip logic)
  $_MUX_:         6   (outlier routing mux)
```

### OpenLane SKY130 Results

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
```

200 constrained-random transactions, including a `force_boundary` constraint
(~15% of transactions) that forces `abs(data_in) == threshold` — without it,
the exact-equality boundary case is a single point in a ~256×256 random space
and is very unlikely to get hit by chance. `cp_round_mode` hitting 100% only
confirms both values were driven as stimulus; `round_mode` has no effect on
DUT behavior until phase 2 (rounding path) is implemented.

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
