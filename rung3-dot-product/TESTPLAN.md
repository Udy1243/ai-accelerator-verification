# Test Plan — Rung 3: Dot Product Engine

## 1. Design Under Test

The `dot_product_engine` module computes the dot product of two 8-element
INT4 signed vectors: result = sum(a[i] * b[i]) for i = 0..7.

Internally it instantiates 8 parallel `mac_unit` blocks from Rung 1.
The interface uses AXI-Stream (tvalid/tready/tlast) for flow control.

Parameters: VECTOR_LEN=8, DATA_WIDTH=4, ACCUM_WIDTH=11

## 2. Verification Goals

| ID | Property |
|----|----------|
| P1 | result = sum(a[i] * b[i]) for i=0..7, all INT4 signed inputs |
| P2 | result = 0 when all inputs are zero |
| P3 | Signed arithmetic correct for negative inputs |
| P4 | Accumulator does not overflow for any valid INT4 input combination |
| P5 | AXI-Stream transfer occurs only when tvalid AND tready are both high |
| P6 | Engine stalls (holds data, does not advance) when tready=0 |
| P7 | tlast asserts on the final vector pair of a transaction |
| P8 | Back-to-back transactions produce correct independent results |

## 3. Directed Test Cases

| Test | Inputs | Expected | Property |
|------|--------|----------|----------|
| All zeros | a=[0..0], b=[0..0] | result=0 | P2 |
| Identity element 0 | a=[1,0,0,0,0,0,0,0], b=[1,0,0,0,0,0,0,0] | result=1 | P1 |
| Identity element 7 | a=[0,0,0,0,0,0,0,1], b=[0,0,0,0,0,0,0,1] | result=1 | P1 |
| All max positive | a=[7..7], b=[7..7] | result=392 | P1, P4 |
| All max negative×positive | a=[-8..-8], b=[7..7] | result=-448 | P3, P4 |
| All max negative×negative | a=[-8..-8], b=[-8..-8] | result=512 | P3, P4 |
| Alternating signs | a=[7,-8,7,-8,7,-8,7,-8], b=[1,1,1,1,1,1,1,1] | result=-4 | P3 |
| Backpressure | tready toggled low mid-transaction | result unchanged, no data lost | P5, P6 |
| Back-to-back | two transactions, no idle cycle between them | both results correct | P8 |

## 4. Random Strategy

Python reference model (`sim/ref_model.py`) generates 1000 random vector pairs:
- 400 vectors: both a and b uniform random INT4 (−8 to 7)
- 300 vectors: a or b contains at least one extreme value (±7 or −8)
- 200 vectors: mixed signs — some elements positive, some negative
- 100 vectors: sparse — most elements zero, 1–3 nonzero

Vectors and expected results written to `sim/stimulus.txt` and
`sim/expected.txt` with seed=42 for reproducibility.

SV testbench reads these files and drives the DUT, comparing
monitor output against expected results (same approach as Rung 2).

## 5. Coverage Model (UVM)

| Bin | Description |
|-----|-------------|
| all_zero | All elements of a and b are 0 |
| all_max_pos | All elements = 7 |
| all_max_neg | All elements = −8 |
| mixed_signs | At least one positive and one negative element per vector |
| sparse | At least 5 of 8 elements are zero |
| backpressure_seen | tready=0 occurred during at least one transaction |
| no_backpressure | tready always high for at least 10 consecutive transactions |
| back_to_back | tlast of transaction N and tvalid of transaction N+1 in same cycle |

## 6. Pass/Fail Criteria

Verification is complete when:
- All 9 directed tests print PASS
- 1000/1000 random vectors pass with 0 mismatches
- All 8 functional coverage bins above have been hit
- UVM test exits with 0 UVM_ERROR and 0 UVM_FATAL
- Yosys synthesis completes with 0 errors
