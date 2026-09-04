# Transformer Inference Accelerator — RTL Design & Verification

A SystemVerilog hardware project exploring the RTL design, verification, and physical implementation of low-precision transformer inference hardware.

The project builds from fundamental MAC and quantization blocks into an **8-element dot-product engine**, a **GEAR-inspired outlier-aware quantizer**, and a **scaled dot-product attention accelerator** with fixed-point softmax.

Verification includes **Python co-simulation, UVM, SystemVerilog Assertions (SVA), functional coverage, and directed testing**, with selected RTL blocks taken through the full **OpenLane RTL-to-GDS flow on the SKY130 PDK**.

## Highlights

* Designed a multi-block transformer inference pipeline in SystemVerilog
* Implemented parameterized **INT4 / INT8 / INT16 MAC hardware**
* Built an **INT4 / INT8 quantizer** with rounding and saturation
* Designed an **8-element AXI-Stream dot-product engine**
* Implemented a **GEAR-inspired outlier-aware INT4 quantizer**
* Built a scaled dot-product **attention unit with fixed-point softmax**
* Developed reusable **UVM verification environments**
* Added concurrent **SystemVerilog Assertions using `bind`**
* Verified **1,000 / 1,000 Python co-simulation vectors**
* Verified **200 / 200 UVM transactions** for the GEAR quantizer
* Achieved **100% functional coverage across 7 covergroups** for the verified GEAR environment
* Completed **RTL-to-GDS using OpenLane + SKY130** for selected blocks

## Architecture

The project was developed incrementally, with each stage introducing a new RTL or verification concept.

| Stage | Module                | Focus                                                |
| ----- | --------------------- | ---------------------------------------------------- |
| 1     | Parameterized MAC     | Signed arithmetic, accumulation, parameterization    |
| 2     | INT4 / INT8 Quantizer | Fixed-point arithmetic, rounding, saturation         |
| 3     | Dot Product Engine    | Parallel MAC array, AXI-Stream, FSM control          |
| 4     | GEAR Quantizer        | Outlier-aware quantization, UVM, coverage, SVA       |
| 5     | Attention Accelerator | QKᵀ computation, scaling, softmax, attention control |

### Dataflow

`Q / K Inputs → Dot Product → Scaling → Softmax → Attention Output`

Supporting blocks provide quantization and outlier-aware compression for low-precision inference.

---

## Stage 1 — Parameterized MAC Unit

A synthesizable multiply-accumulate unit supporting configurable input and accumulator widths.

### Features

* Signed multiplication and accumulation
* Parameterized INT4, INT8, and INT16 configurations
* Active-low reset
* Accumulator clear control
* Valid input/output signaling

### Verification

Directed tests cover:

* Positive accumulation
* Negative operands
* Maximum positive and negative values
* Accumulator clearing
* Long accumulation sequences
* Overflow-sensitive cases

### Yosys Synthesis

| Configuration | Total Cells |
| ------------- | ----------: |
| INT4          |         786 |
| INT8          |       1,137 |
| INT16         |       3,493 |

The synthesis results demonstrate the hardware cost of increasing arithmetic precision, particularly inside multiplier logic.

---

## Stage 2 — INT4 / INT8 Quantizer

A configurable quantization block that converts signed 16-bit values into lower-precision integer representations.

### Datapath

`Input × Scale → Round → Saturate → Register → Quantized Output`

### Features

* INT4 / INT8 output modes
* Truncation and round-to-nearest
* Saturation detection
* Fixed-point scaling
* Valid input/output signaling

### Verification

A Python golden model generates randomized inputs and expected results.

**Result: 1,000 / 1,000 randomized vectors passed**

The test distribution includes both saturating and non-saturating cases to exercise the full quantizer range.

### OpenLane / SKY130

| Metric                  |     Result |
| ----------------------- | ---------: |
| Core Area               | 33,344 µm² |
| Logic Cells             |        830 |
| Critical Path           |    7.05 ns |
| Estimated Max Frequency |    142 MHz |
| Total Power             |   ~0.34 mW |
| Routing Violations      |          0 |
| LVS Errors              |          0 |

---

## Stage 3 — AXI-Stream Dot Product Engine

An 8-element INT4 dot-product accelerator built using eight parallel MAC units.

The engine computes:

`result = Σ a[i] × b[i]`

for two 8-element input vectors.

### Architecture

`AXI-Stream Input → FSM Controller → 8 Parallel MACs → Summation → Output`

### Features

* 8 parallel MAC instances
* INT4 input operands
* AXI-Stream-style `tvalid`, `tready`, and `tlast` interface
* 3-state controller:

  * `IDLE`
  * `COMPUTE`
  * `DONE`
* Parameterized vector and data widths

### Verification

Directed tests cover:

* Zero vectors
* Identity cases
* Maximum positive values
* Maximum negative values
* Mixed signs
* Alternating signs

A UVM environment was also developed containing:

* Sequence
* Sequencer
* Driver
* Monitor
* Scoreboard
* Environment
* Test

The scoreboard independently recomputes the expected dot product and compares it against the DUT output.

Clocking blocks are used to prevent race conditions between the DUT and verification environment.

### Yosys Synthesis

* **1,598 total cells**
* **8 parallel MAC instances**
* **76 flip-flops**
* **442 XOR gates**

The MAC array dominates the area, as expected for an arithmetic accelerator.

---

## Stage 4 — GEAR-Inspired Outlier-Aware Quantizer

A hardware implementation inspired by the outlier-handling concepts used in GEAR-style quantization.

Standard low-bit quantization can lose significant precision when a small number of values are much larger than the rest of the tensor.

This design separates those values into a higher-precision sideband path.

### Concept

For each input:

* If the magnitude exceeds the configured threshold:

  * Mark it as an outlier
  * Preserve the value on an INT8 sideband
* Otherwise:

  * Quantize the value to INT4

Conceptually:

`Normal Values → INT4`

`Outliers → INT8 Sideband`

This allows most data to remain low precision without forcing extreme values into the same INT4 range.

### UVM Verification

A full UVM environment was developed with:

* Transaction class
* Sequence
* Sequencer
* Driver
* Monitor
* Scoreboard
* Coverage collector
* Environment

### Results

* **200 / 200 UVM transactions passed**
* **100% functional coverage**
* **7 functional covergroups**
* Concurrent SVA assertions integrated using `bind`

Coverage targets include:

* Positive and negative inputs
* Outlier / non-outlier behavior
* Threshold boundaries
* Rounding modes
* Saturation behavior
* Cross coverage between major operating conditions

The verification process also exposed a real bug in the coverage collector, which was root-caused and corrected.

### OpenLane / SKY130

| Metric                  |    Result |
| ----------------------- | --------: |
| Standard Cells          |       253 |
| Area                    | 6,314 µm² |
| Estimated Max Frequency |  75.8 MHz |
| Total Power             |  ~0.14 mW |
| DRC Violations          |         0 |
| LVS Violations          |         0 |

Generated physical-design artifacts include:

* GDS
* LEF
* SPICE netlist
* Gate-level netlist

---

## Stage 5 — Scaled Dot-Product Attention

The final stage extends the project from individual arithmetic blocks into a transformer attention datapath.

Scaled dot-product attention follows:

`Attention(Q,K,V) = softmax(QKᵀ / √dₖ)V`

The current RTL focuses on the hardware control and arithmetic required to compute attention scores.

### Major Components

* Dot-product computation
* Fixed scaling
* Numerically stable softmax
* Exponential lookup table
* Fixed-point probability representation
* Multi-state FSM control

### Softmax

Rather than implementing floating-point exponentials directly in hardware, the design uses a lookup-table-based approximation and fixed-point arithmetic.

The output uses a fixed-point representation suitable for downstream hardware.

### Verification

The attention block has been exercised using directed testing and Python-based reference-model comparison.

A UVM environment and functional coverage infrastructure have also been written for this stage and are maintained separately from the completed GEAR UVM results above.

---

## Verification Strategy

This project intentionally uses multiple verification techniques rather than relying on a single testbench methodology.

### Directed Testing

Used for:

* Basic arithmetic correctness
* Boundary conditions
* FSM behavior
* Reset behavior
* Known corner cases

### Python Co-Simulation

Python acts as a software golden model for mathematical blocks such as quantization and attention calculations.

This provides an implementation-independent reference against which the RTL can be checked.

### UVM

UVM environments exercise the RTL with reusable transaction-level verification components.

Key components include:

`Sequence → Sequencer → Driver → DUT → Monitor → Scoreboard`

Functional coverage tracks whether important input spaces and operating conditions have actually been exercised.

### SystemVerilog Assertions

Concurrent SVA properties check protocol and temporal behavior that is difficult to verify through output comparison alone.

Assertions are connected using `bind` so verification properties remain separated from synthesizable RTL.

---

## Physical Design

Selected blocks were taken beyond RTL synthesis through the complete OpenLane ASIC flow.

`SystemVerilog RTL`

`↓`

`Yosys Synthesis`

`↓`

`Floorplanning`

`↓`

`Placement`

`↓`

`Clock Tree Synthesis`

`↓`

`Routing`

`↓`

`DRC / LVS`

`↓`

`GDSII`

Technology:

**SkyWater SKY130**

The goal of this portion of the project was to connect RTL design decisions with physical consequences including:

* Cell count
* Area
* Timing
* Power
* Routing
* Physical verification

---

## Repository Structure

```text
ai-accelerator-verification/
│
├── rung0-toolchain/
├── rung1-mac-unit/
├── rung2-quantizer/
├── rung3-dot-product/
├── rung4-gear-quantizer/
└── rung5-attention/
```

Each stage contains its own combination of:

* `rtl/` — synthesizable SystemVerilog
* `tb/` — testbench / verification code
* `openlane/` — physical-design configuration and results
* `Makefile` — simulation and synthesis commands
* `README.md` — module-specific documentation

---

## Tools & Technologies

### RTL & Verification

* SystemVerilog
* UVM 1.2
* SystemVerilog Assertions
* Functional Coverage
* AXI-Stream
* Python reference models

### Simulation

* iverilog
* Aldec Riviera-PRO
* GTKWave

### Synthesis & ASIC Flow

* Yosys
* OpenLane
* SKY130 PDK

### Programming

* Python
* Make
* Shell / Linux

---

## What I Learned

This project was built to explore the complete digital hardware development loop:

`Algorithm → Architecture → RTL → Verification → Synthesis → Physical Design`

The most important takeaway was that correct RTL is only one part of hardware design.

Building UVM scoreboards, debugging timing between drivers and monitors, measuring functional coverage, writing assertions, and taking blocks through physical implementation exposed issues and tradeoffs that are not visible from behavioral simulation alone.

The project also provided experience translating machine-learning concepts such as quantization, outlier handling, dot products, and softmax into synthesizable fixed-point hardware.

---

## Project Status

* [x] Parameterized MAC
* [x] INT4 / INT8 quantizer
* [x] Python co-simulation
* [x] AXI-Stream dot-product engine
* [x] Dot-product UVM environment
* [x] GEAR-inspired outlier-aware quantizer
* [x] GEAR UVM verification
* [x] Functional coverage
* [x] SystemVerilog Assertions
* [x] OpenLane RTL-to-GDS
* [x] Scaled dot-product attention RTL
* [x] Attention reference-model testing
* [x] Attention UVM infrastructure
* [ ] Additional attention-level UVM regression and coverage closure

---

## Author

**Uday Gunturu**
Electrical & Computer Engineering
The University of Texas at Austin

Interested in **RTL Design, Design Verification, Computer Architecture, and AI Hardware Acceleration**.
