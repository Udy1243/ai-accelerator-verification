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
tb/uvm/                   — UVM testbench (in progress)
Makefile                  — sim / cosim / synth / waves targets
TESTPLAN.md               — verification plan
```
