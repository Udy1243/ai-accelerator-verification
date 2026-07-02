# Rung 1 — Parameterized INT8 MAC Unit

A synthesizable multiply-accumulate unit in SystemVerilog, 
verified with a self-checking directed testbench and synthesized 
via Yosys across three precision variants.

## What it does

Takes two signed integer inputs, multiplies them, and accumulates 
the result into a running total. This is the fundamental compute 
primitive inside every neural network — every dot product in a 
matrix multiplication is a sequence of MAC operations.

## Design

| Signal     | Direction | Width          | Description                        |
|------------|-----------|----------------|------------------------------------|
| clk        | input     | 1              | Clock                              |
| rst_n      | input     | 1              | Active-low reset                   |
| valid_in   | input     | 1              | Accumulate when high               |
| a, b       | input     | INPUT_WIDTH    | Signed operands                    |
| clear      | input     | 1              | Reset accumulator to zero          |
| accum_out  | output    | ACCUM_WIDTH    | Running total                      |
| valid_out  | output    | 1              | High after first valid accumulation|

## Verification

Six directed tests covering:

| Test | Description | Expected |
|------|-------------|----------|
| 1 | Basic accumulation 3×4 + 2×5 | 22 |
| 2 | Clear resets accumulator | 1 |
| 3 | Negative input -4×3 | -12 |
| 4 | Max negative squared -128×-128 | 16384 |
| 5 | 16x accumulation of 2×3 | 96 |
| 6 | 128x accumulation of 127×127 | 2,064,512 |

All six tests pass. The overflow test (Test 6) validates that a 
32-bit accumulator correctly holds the result of 128 accumulated 
multiplications without wrapping.

## Synthesis Results (Yosys)

| Variant | Input Width | Accum Width | Total Cells | Flip Flops | XOR Gates |
|---------|-------------|-------------|-------------|------------|-----------|
| INT4    | 4-bit       | 32-bit      | 786         | 33         | 183       |
| INT8    | 8-bit       | 32-bit      | 1,137       | 33         | 287       |
| INT16   | 16-bit      | 64-bit      | 3,493       | 65         | 887       |

**Key insight:** Cell count scales roughly with N² as input width 
doubles — going from INT8 to INT16 costs 3× more gates almost 
entirely in the multiplier logic. Flip flop count is determined 
by ACCUM_WIDTH, not INPUT_WIDTH — changing input precision changes 
compute logic but not storage.

## How to run

```bash
make sim    # compile and simulate
make synth  # synthesize with Yosys
make waves  # open GTKWave waveform viewer
make clean  # remove build artifacts
```

## Context

This MAC unit is Rung 1 of a four-rung AI accelerator verification 
project building toward a GEAR-inspired outlier-aware INT4 
quantizer with a full UVM testbench and OpenLane synthesis on 
SKY130. The MAC unit is the compute primitive that all subsequent 
rungs build on top of.

# Rung 2 — Parameterized INT4/INT8 Quantizer

A synthesizable quantizer in SystemVerilog that compresses 
16-bit signed integers to INT4 or INT8, verified with directed 
tests and 1,000 constrained-random vectors against a Python 
co-simulation reference model, and synthesized through the full 
RTL-to-GDS flow on SKY130 via OpenLane.

## What it does

Takes a 16-bit signed input and a scale factor, multiplies them, 
applies configurable rounding (truncation or round-to-nearest), 
saturates the result to the output range, and outputs a compressed 
integer. This is the compression step that reduces neural network 
weight storage from 16-bit to 4-bit or 8-bit.

## Design

| Signal      | Direction | Width        | Description                        |
|-------------|-----------|--------------|-------------------------------------|
| clk         | input     | 1            | Clock                               |
| rst_n       | input     | 1            | Active-low reset                    |
| valid_in    | input     | 1            | Input data valid                    |
| data_in     | input     | INPUT_WIDTH  | Raw value to quantize (signed)      |
| scale       | input     | 8            | Scale factor (unsigned)             |
| round_mode  | input     | 1            | 0=truncate, 1=round-to-nearest      |
| data_out    | output    | OUTPUT_WIDTH | Quantized result (signed)           |
| overflow    | output    | 1            | High if saturation occurred         |
| valid_out   | output    | 1            | Output valid                        |

## Pipeline stages
## Verification

| Test | Description | Expected |
|------|-------------|----------|
| 1 | Normal: 5×3, truncate | 15, no overflow |
| 2 | Saturation: 32767×255 | 127, overflow=1 |
| 3 | Negative: -30×3 | -90, no overflow |
| 4 | Rounding: 10×3, round mode | 31, no overflow |
| + | 1,000 constrained-random vectors vs Python golden model | 0 failures |

**Co-simulation methodology:** Python reference model generates 
random test vectors and expected outputs. SV testbench reads 
golden.txt and compares every output — 700 saturation cases 
and 300 non-saturating cases for balanced coverage.

## OpenLane SKY130 Results

| Metric | Value |
|--------|-------|
| Core area | 33,344 µm² |
| Logic cells | 830 |
| Critical path | 7.05 ns |
| Max frequency | 142 MHz |
| Target frequency | 40 MHz |
| Timing slack | +17.95 ns |
| Total power (typical) | ~0.34 mW |
| Routing violations | 0 |
| LVS errors | 0 |

## How to run

```bash
python3 tb/generate_vectors.py   # generate golden vectors
make sim                          # simulate + check 1004 vectors
make synth                        # quick Yosys gate count
```

## Context

Rung 2 of a four-rung AI accelerator verification project. 
The quantizer compresses the MAC unit outputs from Rung 1 
before storage — reducing memory bandwidth by 2-4x while 
the saturation and rounding logic controls accuracy loss.

# Rung 3 — Dot Product Engine with UVM Verification
 
A pipelined 8-element dot product engine in SystemVerilog, verified
with a complete UVM testbench running 100 constrained-random transactions
through a self-checking scoreboard. Synthesized via Yosys with 8 parallel
MAC unit instances.
 
---
 
## What it does
 
Computes the dot product of two INT4 input vectors of length 8:
 
```
result = a[0]*b[0] + a[1]*b[1] + ... + a[7]*b[7]
```
 
This is the core operation inside every neural network layer — each
neuron's activation is a dot product of its inputs against its weights.
The engine uses an AXI-Stream interface for data transfer and a
3-state FSM to sequence the computation.
 
---
 
## Architecture
 
```
AXI-Stream input
(tvalid/tready/tlast)
        │
        ▼
  ┌─────────────┐
  │  FSM        │  IDLE → COMPUTE → DONE
  │  Controller │  tready high in IDLE
  └──────┬──────┘
         │ valid_in / clear
         ▼
  ┌──────────────────────────────────────┐
  │  MAC Array (8 parallel instances)    │
  │  mac[0] mac[1] mac[2] ... mac[7]     │
  │  each: INPUT_WIDTH=4, ACCUM_WIDTH=8  │
  └──────────────┬───────────────────────┘
                 │ mac_out[0..7]
                 ▼
          ┌─────────────┐
          │ always_comb  │  sum all 8 outputs
          │  summation   │
          └──────┬───────┘
                 │
                 ▼
           accum[10:0]  +  accum_valid
```
 
### FSM states
 
| State | Description |
|-------|-------------|
| IDLE | tready=1, clear_mac=1, waiting for tvalid |
| COMPUTE | valid_in_mac=1, MACs accumulate for one cycle |
| DONE | accum_valid=1, result stable, returns to IDLE |
 
---
 
## Parameters
 
| Parameter | Default | Description |
|-----------|---------|-------------|
| VECTOR_LEN | 8 | Number of MAC units |
| DATA_WIDTH | 4 | Input bit width (INT4) |
| ACCUM_WIDTH | 11 | Output accumulator width |
 
Accumulator width of 11 bits handles the worst case:
8 × (7 × 7) = 392 and 8 × ((-8) × (-8)) = 512 — both fit in 11 bits signed.
 
---
 
## Ports
 
| Signal | Direction | Width | Description |
|--------|-----------|-------|-------------|
| clk | input | 1 | Clock |
| rst_n | input | 1 | Active-low reset |
| a_flat | input | DATA_WIDTH×VECTOR_LEN | Flattened vector A |
| b_flat | input | DATA_WIDTH×VECTOR_LEN | Flattened vector B |
| tvalid | input | 1 | AXI-Stream input valid |
| tlast | input | 1 | AXI-Stream last beat |
| tready | output | 1 | AXI-Stream ready |
| accum | output | ACCUM_WIDTH | Dot product result |
| accum_valid | output | 1 | Result is valid this cycle |
 
Ports use flattened packed vectors (`a_flat`, `b_flat`) for Yosys
synthesis compatibility. The RTL unpacks them internally via a
generate block.
 
---
 
## Verification
 
### Directed testbench (7 tests)
 
| Test | Description | Expected |
|------|-------------|----------|
| all_zeroes | All inputs zero | 0 |
| identity_elem_0 | a[0]=1, b[0]=1, rest zero | 1 |
| identity_elem_7 | a[7]=1, b[7]=1, rest zero | 1 |
| all_max_pos | All a=7, b=7 | 392 |
| max_neg_x_max_pos | All a=-8, b=7 | -448 |
| max_neg_x_max_neg | All a=-8, b=-8 | 512 |
| alternating_signs | a alternates 7/-8, b=1 | -4 |
 
All 7 directed tests pass.
 
### UVM testbench (100 constrained-random transactions)
 
Full UVM 1.2 environment running on Aldec Riviera-PRO:
 
```
uvm_sequence
    generates 100 random transactions
         │
         ▼
uvm_sequencer
         │
         ▼
uvm_driver
    drives AXI-Stream handshake
    holds inputs stable until accum_valid
         │
         ▼
    [DUT]
         │
         ▼
uvm_monitor
    captures inputs + result when accum_valid fires
         │
         ▼
uvm_scoreboard
    recomputes expected from captured inputs
    compares against actual output
```
 
**Results: 100 passed, 0 failed**
 
Key implementation decisions:
 
- Driver waits for `accum_valid` before calling `item_done()` — prevents
  the driver loading the next transaction's inputs before the monitor
  captures the current result
- Monitor captures `a_flat`, `b_flat`, and `accum` atomically when
  `accum_valid` fires — avoids stale-input mismatches
- Scoreboard recomputes expected value from captured inputs using the same
  slicing logic as the DUT — independent verification of the hardware math
- Clocking blocks with `#1step` input sampling and `#1` output delay
  eliminate race conditions throughout
---
 
## Synthesis Results (Yosys)
 
```
Design hierarchy total:
  Total cells:    1,598
  Flip flops:        76
  XOR gates:        442
  MAC instances:      8
 
Per MAC unit (INT4, ACCUM_WIDTH=8):
  Cells:   159
  FFs:       9
 
Dot product controller:
  Cells:   334
  FFs:       4  (2-bit state + accum_valid + 1 misc)
```
 
**Key insight:** 8 MAC units × 159 cells = 1,272 cells for the compute
array. The FSM and summation add only 334 cells — the compute logic
dominates as expected for an arithmetic accelerator.
 
---
 
## How to run
 
```bash
# Directed testbench (iverilog)
make sim
 
# Synthesis gate count (Yosys)
make synth
 
# Waveforms (GTKWave)
make waves
```
 
UVM testbench runs on [EDA Playground](https://edaplayground.com) with
UVM 1.2 and Aldec Riviera-PRO — paste `tb/uvm/testbench.sv` into the
testbench panel and `rtl/mac_unit.sv` + `rtl/dot_product.sv` into the
design panel.
 
---
 
## Context
 
Rung 3 of a four-rung AI accelerator verification project. The dot product
engine builds on the INT8 MAC unit from Rung 1 and feeds into the
GEAR-inspired outlier quantizer in Rung 4. The UVM environment established
here — driver, monitor, scoreboard, clocking blocks — scales directly to
the full UVM testbench in Rung 4.

# Rung 4 — GEAR-Inspired Outlier-Aware INT4 Quantizer

A SystemVerilog quantizer that detects per-value outliers against a
configurable threshold and routes them to a full-precision INT8 sideband
path instead of quantizing them to INT4, preserving accuracy on the values
that matter most.

## What it does

```
if abs(data_in) > threshold:
    is_outlier = 1, sideband_out = data_in, int4_out = 0
else:
    is_outlier = 0, int4_out = clip(data_in x scale, -8, 7), sideband_out = 0
```

## Verification

| Test | Description | Expected |
|------|-------------|----------|
| 1-6 | Directed: normal quantization, positive/negative outlier, boundary, scale=0, negative normal | 6/6 pass |
| + | 1,000 random vectors vs Python golden model | 0 failures |
| + | UVM: 200 constrained-random transactions (EDA Playground) | 200/200 pass, 0 UVM_ERROR |
| + | Functional coverage: 6 covergroups | 100% all bins |

## OpenLane SKY130 Results

| Metric | Value |
|--------|-------|
| Core area | 5,780.5 um^2 |
| Logic cells | 233 |
| Core utilization | 42.5% |
| Critical path | 3.88 ns |
| Max frequency | 257.7 MHz |
| Target frequency | 40 MHz |
| Timing slack | +21.12 ns |
| Total power (typical) | ~0.117 mW |
| Routing violations | 0 |
| LVS errors | 0 |

## How to run

```bash
python3 tb/generate_vectors.py   # generate golden vectors
make cosim                        # simulate + check 1000 vectors
make synth                        # quick Yosys gate count
```

OpenLane SKY130 flow: `cd ~/OpenLane && make mount`, then inside the
container run `./flow.tcl -design <path-to>/rung4-gear-quantizer/openlane -overwrite`.

## Context

Rung 4 of a four-rung AI accelerator verification project. It closes the
loop on the GEAR-inspired quantization concept the whole project builds
toward, with a full UVM testbench and 100% functional coverage on
EDA Playground (Aldec Riviera-PRO, UVM 1.2), following the Rung 3
template. Next up: implement the `round_mode` rounding path (phase 2).
 