# Test Plan — Rung 2: INT4/INT8 Quantizer

## 1. Design Under Test

The `quantizer` module compresses a 16-bit signed integer to
OUTPUT_WIDTH bits (default 8) by multiplying by a scale factor,
applying configurable rounding, and saturating to the output range.
Overflow is flagged when saturation occurs.

Parameters: INPUT_WIDTH (default 16), OUTPUT_WIDTH (default 8)

## 2. Verification Goals

| ID | Property |
|----|----------|
| P1 | data_out = clip(data_in × scale, MIN_VAL, MAX_VAL) |
| P2 | overflow = 1 if and only if saturation occurred |
| P3 | round_mode=0 truncates, round_mode=1 adds 1 before output |
| P4 | scale=0 is excluded — undefined behavior by design |
| P5 | Negative data_in produces correct signed output |
| P6 | data_out never exceeds MAX_VAL or goes below MIN_VAL |

## 3. Directed Test Cases

| Test | Inputs | Expected | Property |
|------|--------|----------|----------|
| Normal | data_in=5, scale=3, mode=0 | out=15, ovf=0 | P1 |
| Positive saturation | data_in=32767, scale=255, mode=0 | out=127, ovf=1 | P2, P6 |
| Negative input | data_in=-30, scale=3, mode=0 | out=-90, ovf=0 | P5 |
| Rounding | data_in=10, scale=3, mode=1 | out=31, ovf=0 | P3 |

## 4. Random Strategy

Python reference model generates 1000 random vectors:
- 700 large-value vectors (data_in up to ±32767, scale up to 255)
  → exercises saturation path heavily
- 300 small-value vectors (data_in -10 to 10, scale 1 to 10)
  → exercises normal quantization path

Uniform random alone would produce almost exclusively saturating
cases — the split distribution ensures both paths are exercised.

seed=42 ensures reproducibility between Python generation and
SV testbench reading.

## 5. Coverage Model

| Bin | Description | Status |
|-----|-------------|--------|
| No overflow | result fits in OUTPUT_WIDTH | ✓ 300 vectors |
| Positive overflow | result > MAX_VAL | ✓ ~500 vectors |
| Negative overflow | result < MIN_VAL | ✓ ~200 vectors |
| Truncation mode | round_mode=0 | ✓ ~500 vectors |
| Round-to-nearest | round_mode=1 | ✓ ~500 vectors |
| Max positive scale | scale=255 | ✓ Test 2 |
| Min scale | scale=1 | ✓ included in random |
| Max positive data | data_in=32767 | ✓ Test 2 |
| Max negative data | data_in=-32768 | ✓ included in random |

## 6. Pass/Fail Criteria

Verification is complete when:
- All 4 directed tests print PASS
- 1000/1000 random vectors pass with 0 failures
- All coverage bins above have been exercised
- OpenLane flow completes with 0 routing violations and 0 LVS errors
- Timing closure achieved at target clock period