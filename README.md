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
