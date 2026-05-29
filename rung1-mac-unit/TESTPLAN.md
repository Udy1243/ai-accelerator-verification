# Test Plan — Rung 1: INT8 MAC Unit

## 1. Design Under Test

The `mac_unit` module is a parameterized multiply-accumulate unit
that takes two signed integer inputs (a, b), multiplies them, and
adds the result to a running accumulator register. The accumulator
clears on `clear` and only updates when `valid_in` is high.

Parameters: INPUT_WIDTH (default 8), ACCUM_WIDTH (default 32)

## 2. Verification Goals

The following properties must hold for all inputs:

| ID | Property |
|----|----------|
| P1 | accum_out = sum of all (a × b) products since last clear |
| P2 | accum_out does not change when valid_in is low |
| P3 | clear resets accum_out to zero on the next clock edge |
| P4 | rst_n=0 forces accum_out to zero regardless of other inputs |
| P5 | accum_out does not overflow for 128 accumulations of max product |
| P6 | Negative inputs produce correct signed products |

## 3. Directed Test Cases

| Test | Inputs | Expected | Property |
|------|--------|----------|----------|
| Basic accumulation | a=3,b=4 then a=2,b=5 | 22 | P1 |
| Clear works | accumulate then clear then a=1,b=1 | 1 | P3 |
| Negative input | a=-4, b=3 | -12 | P6 |
| Max negative squared | a=-128, b=-128 | 16384 | P6 |
| 16x accumulation | repeat 16x a=2,b=3 | 96 | P1 |
| Overflow check | repeat 128x a=127,b=127 | 2,064,512 | P5 |

## 4. Random Strategy

Not yet implemented — planned for Rung 3 UVM environment.
Rung 1 uses directed testing only to establish baseline correctness.

## 5. Coverage Model

| Bin | Description | Status |
|-----|-------------|--------|
| positive × positive | Both inputs positive | ✓ Tests 1, 5, 6 |
| negative × positive | One input negative | ✓ Test 3 |
| negative × negative | Both inputs negative | ✓ Test 4 |
| max positive input | a or b = 127 | ✓ Test 6 |
| max negative input | a or b = -128 | ✓ Test 4 |
| clear after accumulation | clear=1 after non-zero accum | ✓ Test 2 |
| large accumulation count | 16+ accumulations | ✓ Tests 5, 6 |

## 6. Pass/Fail Criteria

Verification is complete when:
- All 6 directed tests print PASS
- Yosys synthesis produces correct flip flop count (33 for INT8)
- INT4/INT8/INT16 synthesis comparison table completed
- No overflow observed with 32-bit accumulator on 128 max products