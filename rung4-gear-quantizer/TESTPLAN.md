# Test Plan — Rung 4: GEAR Outlier-Aware INT4 Quantizer

## 1. Design Under Test

The `gear_quantizer` module implements GEAR-inspired outlier-aware quantization.
Each 8-bit signed input is routed to one of two paths based on a configurable
threshold: values exceeding the threshold are flagged as outliers and passed
through at full INT8 precision via a sideband; values within range are
quantized to INT4 by multiplying by a 4-bit unsigned scale factor and clipping.

Parameters: DATA_WIDTH=8, INT4_WIDTH=4

## 2. Verification Goals

| ID | Property |
|----|----------|
| P1 | Non-outlier: int4_out = clip(data_in × scale, −8, 7); sideband_out = 0 |
| P2 | Outlier: is_outlier = 1; sideband_out = data_in; int4_out = 0 |
| P3 | Outlier detection uses strict inequality: abs(data_in) > threshold |
| P4 | Boundary: abs(data_in) == threshold is NOT an outlier |
| P5 | Clip saturates correctly: product > 7 → int4_out = 7; < −8 → int4_out = −8 |
| P6 | Signed arithmetic correct for negative data_in values |
| P7 | scale = 0 produces int4_out = 0 for non-outliers |
| P8 | valid_out follows valid_in with exactly 1 cycle latency |
| P9 | All outputs reset to 0 on rst_n assertion |

## 3. Directed Test Cases

| Test | data_in | threshold | scale | Expected | Property |
|------|---------|-----------|-------|----------|----------|
| Normal quantization | 8 | 20 | 2 | int4=7 (clips from 16) | P1, P5 |
| Positive outlier | 30 | 20 | 2 | is_outlier=1, sideband=30 | P2 |
| Negative outlier | −25 | 20 | 2 | is_outlier=1, sideband=−25 | P2, P6 |
| Boundary (abs==threshold) | 20 | 20 | 1 | is_outlier=0, int4=7 | P3, P4 |
| Scale zero | 10 | 20 | 0 | is_outlier=0, int4=0 | P7 |
| Negative normal | −4 | 20 | 1 | is_outlier=0, int4=−4 | P6 |

## 4. Random Strategy

Python golden model (`tb/generate_vectors.py`) generates 1000 random vectors:
- `data_in`: uniform random signed INT8 (−128 to 127)
- `threshold`: uniform random (0 to 100) — chosen so ~half of inputs are outliers
- `scale`: uniform random INT4 unsigned (0 to 15)

Each vector's expected outputs are computed by the Python golden model and
written to `sim/vectors.txt` (space-separated). The SV co-sim testbench
(`tb/tb_cosim.sv`) reads this file, drives the DUT, and compares all outputs.

The random threshold range (0–100) ensures a mix of outlier and non-outlier
cases across the 1000 vectors rather than always saturating one path.

## 5. Coverage Model

| Covergroup | Bins | Target |
|------------|------|--------|
| Input range | negative / zero / positive | All 3 hit |
| Outlier flag | is_outlier=0 / is_outlier=1 | Both hit |
| Threshold boundary | abs < threshold / abs == threshold / abs > threshold | All 3 hit |
| Clip boundary | int4_out at −8 / middle range / at +7 | All 3 hit |
| Scale | 0 / mid (1–14) / max (15) | All 3 hit |
| Round mode | truncate (0) / round-to-nearest (1) | Both hit (phase 2) |

## 6. Pass/Fail Criteria

Verification is complete when:
- All 6 directed tests print PASS
- 1000/1000 co-sim vectors pass with 0 mismatches
- All functional coverage bins above have been hit (UVM phase)
- Yosys synthesis completes with 0 errors
- OpenLane SKY130 flow completes with 0 DRC/LVS violations
