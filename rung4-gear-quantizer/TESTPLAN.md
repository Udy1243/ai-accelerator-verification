# Test Plan — Rung 4: GEAR Outlier-Aware INT4 Quantizer

## 1. Design Under Test

The `gear_quantizer` module implements GEAR-inspired outlier-aware quantization.
Each 8-bit signed input is routed to one of two paths based on a configurable
threshold: values exceeding the threshold are flagged as outliers and passed
through at full INT8 precision via a sideband; values within range are
quantized to INT4 by scaling down with a fixed-point fraction (`scale/16`) and
clipping. `scale` can only attenuate, never amplify, `data_in`. `round_mode`
selects between truncating the shift and rounding to nearest based on the MSB
of the 4 dropped bits.

Parameters: DATA_WIDTH=8, INT4_WIDTH=4

## 2. Verification Goals

| ID | Property |
|----|----------|
| P1 | Non-outlier: int4_out = clip(round_or_trunc((data_in × scale) >> 4, round_mode), −8, 7); sideband_out = 0 |
| P2 | Outlier: is_outlier = 1; sideband_out = data_in; int4_out = 0 |
| P3 | Outlier detection uses strict inequality: abs(data_in) > threshold |
| P4 | Boundary: abs(data_in) == threshold is NOT an outlier |
| P5 | Clip saturates correctly: product > 7 → int4_out = 7; < −8 → int4_out = −8 |
| P6 | Signed arithmetic correct for negative data_in values |
| P7 | scale = 0 produces int4_out = 0 for non-outliers |
| P8 | valid_out follows valid_in with exactly 1 cycle latency |
| P9 | All outputs reset to 0 on rst_n assertion |
| P10 | round_mode changes int4_out on identical inputs when the dropped nibble's MSB is 1 |
| P11 | Clip still saturates correctly on values pushed over INT4_MAX/MIN by rounding |

## 3. Directed Test Cases

| Test | data_in | threshold | scale | round_mode | Expected | Property |
|------|---------|-----------|-------|------------|----------|----------|
| Normal quantization | 8 | 20 | 2 | 0 | int4=1 (16>>4, no round) | P1 |
| Positive outlier | 30 | 20 | 2 | 0 | is_outlier=1, sideband=30 | P2 |
| Negative outlier | −25 | 20 | 2 | 0 | is_outlier=1, sideband=−25 | P2, P6 |
| Boundary (abs==threshold) | 20 | 20 | 1 | 0 | is_outlier=0, int4=1 | P3, P4 |
| Scale zero | 10 | 20 | 0 | 0 | is_outlier=0, int4=0 | P7 |
| Negative normal, truncate | −4 | 20 | 1 | 0 | is_outlier=0, int4=−1 | P6 |
| Round changes result (truncate) | 8 | 20 | 3 | 0 | int4=1 (rem=8, truncated) | P1 |
| Round changes result (round) | 8 | 20 | 3 | 1 | int4=2 (same inputs as above, rounds up) | P10 |
| Round-then-clip (truncate) | 127 | 127 | 1 | 0 | int4=7 (at max, no overflow) | P5 |
| Round-then-clip (round) | 127 | 127 | 1 | 1 | int4=7 (rounds to 8, clips back to 7) | P5, P11 |

## 4. Random Strategy

Python golden model (`tb/generate_vectors.py`) generates 1000 random vectors:
- `data_in`: uniform random signed INT8 (−128 to 127)
- `threshold`: uniform random (0 to 100) — chosen so ~half of inputs are outliers
- `scale`: uniform random INT4 unsigned (0 to 15)
- `round_mode`: uniform random bit (0 or 1)

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
| Round mode | truncate (0) / round-to-nearest (1) | Both hit |
| Round applied | round-up increment fired / did not fire | Both hit — proves round_mode changes behavior, not just driven as stimulus |

## 6. Pass/Fail Criteria

Verification is complete when:
- All 10 directed tests print PASS
- 1000/1000 co-sim vectors pass with 0 mismatches
- All functional coverage bins above have been hit (UVM phase)
- Yosys synthesis completes with 0 errors
- OpenLane SKY130 flow completes with 0 DRC/LVS violations

**Status: OpenLane complete.** Flow finished with 0 routing violations,
0 antenna violations, 0 LVS errors — 233 cells, 5,780.5 µm² core area at
42.5% utilization, 257.7 MHz max frequency, ~0.117 mW typical power.

**Status: UVM + functional coverage complete (phase 1).** EDA Playground
(Aldec Riviera-PRO 2025.04, UVM 1.2), 200 constrained-random transactions
(including a `force_boundary` bias constraint to guarantee the exact
`abs(data_in) == threshold` bin gets hit) — scoreboard: 200/200 passed,
0 UVM_ERROR/UVM_FATAL. All 6 covergroups hit 100% coverage. Note:
`cp_round_mode` reaching 100% only confirms both values were driven as
stimulus — `round_mode` has no effect on DUT behavior until the phase 2
rounding path is implemented, so that bin isn't a meaningful functional
check yet.

**Status: phase 2 (round_mode rounding path) implemented.** RTL, directed
tests (10/10), and Python co-sim (1000/1000) all updated and passing under
the new fixed-point scale semantics (`scale` now means `scale/16`,
attenuate-only). UVM `testbench.sv` updated to match — golden model in
`compute_expected()` now includes the shift/round path, and a new
`cp_round_applied` covergroup bin tracks whether the round-up increment
actually fired, addressing the "not a meaningful check yet" note above.
Needs re-running on EDA Playground to confirm 200/200 + 100% coverage
against the updated model, since UVM can't be run locally. Yosys
re-synthesized: 343 cells (was 329), 14 flip-flops (unchanged, new logic
is combinational). OpenLane SKY130 numbers below are stale (from the
phase-1 RTL) and should be re-run once the UVM re-run confirms phase 2.
