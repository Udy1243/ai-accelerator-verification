# AI Accelerator Verification Project

## What this project is
A four-rung hardware verification project building toward a
GEAR-inspired INT4 outlier-aware quantizer with a full UVM
testbench, targeting Nvidia/Apple hardware verification internships.

## Student background
- ECE student at UT Austin, sophomore, GPA 3.8
- Comfortable with C/C++, Python, Embedded C
- Learning SystemVerilog and hardware verification from scratch
- Using iverilog (not commercial tools) — must use iverilog-compatible SV
- Has completed: Rung 1, Rung 2, Rung 3, CUDA matmul, simple CPU

## Current status
- Rung 1 (INT8 MAC unit): COMPLETE
  - 6 directed tests passing including overflow test
  - Yosys synthesis: INT4=786, INT8=1137, INT16=3493 cells, 33 flip flops
  - TESTPLAN.md + README written

- Rung 2 (INT4/INT8 Quantizer): COMPLETE
  - 4 directed tests + 1000 random vectors from Python co-sim (0 failures)
  - OpenLane SKY130: 33344um2, 142MHz max, 0.34mW, 0 violations
  - TESTPLAN.md + README written

- Rung 3 (Dot product engine + UVM): COMPLETE
  - dot_product.sv: 8 MAC instances, AXI-Stream, 3-state FSM (IDLE/COMPUTE/DONE)
  - Flattened ports: a_flat/b_flat [DATA_WIDTH*VECTOR_LEN-1:0] for Yosys compat
  - 7 directed tests passing on iverilog
  - Yosys: 1598 total cells, 8 MAC instances, 76 flip flops
  - Full UVM env on EDA Playground (Aldec Riviera-PRO, UVM 1.2)
  - 100 constrained-random transactions — 0 failures
  - TESTPLAN.md + README written

- Rung 4 (GEAR outlier quantizer): IN PROGRESS
  - gear_quantizer.sv RTL complete
  - Directed testbench: 6/6 passing (tb_gear_quantizer.sv)
  - Python co-sim: 1000/1000 passing (generate_vectors.py + tb_cosim.sv)
  - Yosys synthesis: 329 cells, 14 flip-flops, 0 errors
  - TESTPLAN.md + README.md written
  - round_mode port exists but rounding path not yet implemented (phase 2)
  - Next: OpenLane SKY130 synthesis, UVM testbench with functional coverage

## Toolchain
- WSL2 Ubuntu on Windows, VS Code connected to WSL2
- iverilog -g2012 for simulation (NOT Questa, NOT VCS)
- GTKWave for waveforms
- Yosys for synthesis
- OpenLane + SKY130 at ~/OpenLane (run via make mount Docker)
- Python 3.14 + NumPy for co-simulation golden models
- UVM runs on EDA Playground (edaplayground.com) — Aldec Riviera-PRO 2025.04, UVM 1.2
- make for build automation

## Project structure
rung1-mac-unit/       - INT8 MAC unit (complete)
rung2-quantizer/      - INT4/INT8 quantizer (complete)
rung3-dot-product/    - dot product engine + UVM (complete)
rung4-gear-quantizer/ - GEAR outlier quantizer (in progress)

---

## Rung 4 — what to build

### Concept
GEAR-inspired outlier-aware INT4 quantizer. Instead of quantizing all
values uniformly, it detects outliers (values exceeding a threshold)
and routes them to a higher-precision sideband path.

### Port list (coded in gear_quantizer.sv)
```
Inputs:
  clk          — clock
  rst_n        — active-low reset
  valid_in     — input data valid
  data_in[7:0] — 8-bit signed input value
  threshold[7:0] — outlier detection threshold
  scale[3:0]   — scale factor for INT4 quantization
  round_mode   — 0=truncate, 1=round-to-nearest

Outputs:
  valid_out       — output valid
  is_outlier      — 1 if value exceeded threshold
  int4_out[3:0]   — INT4 quantized result (0 if outlier)
  sideband_out[7:0] — original INT8 value (0 if not outlier)
```

### Logic
```
if abs(data_in) > threshold:
    is_outlier    = 1
    int4_out      = 0
    sideband_out  = data_in  (full precision preserved)
else:
    is_outlier    = 0
    int4_out      = clip(data_in * scale, -8, 7)
    sideband_out  = 0
```

### Verification plan
- Directed tests: normal quantization, outlier detection, boundary cases
- Python co-simulation: generate 1000 random vectors with mixed
  outliers and normal values, verify RTL matches golden model
- UVM testbench on EDA Playground (same structure as Rung 3)
- OpenLane SKY130 synthesis for area/power/timing

---

## CRITICAL: Code conventions — follow these exactly

### RTL conventions

Always use active-low reset:
```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // reset logic
    end else begin
        // normal logic
    end
end
```

Always use always_ff for sequential, always_comb for combinational.
Never use always @(*).

Parameters always at top of module before port list:
```systemverilog
module foo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 4
)(
    input logic clk,
    // ports...
);
```

Signal naming:
- Registers: _reg suffix (accum_reg, state_reg)
- Active-low signals: _n suffix (rst_n)
- Outputs driven by always_ff: declare as logic, assign separately

### Known iverilog limitations — CRITICAL
- NO unpacked arrays as task/function arguments → use module-level signals
- NO unpacked array port declarations → use flattened packed vectors
  e.g. use [DATA_WIDTH*VECTOR_LEN-1:0] a_flat instead of [DATA_WIDTH-1:0] a[VECTOR_LEN]
- NO unpacked array assignments (a = b where both are arrays)
- enums with 3+ states need explicit width: typedef enum logic [1:0] {...}
- Use !== not != for 4-state logic comparison

### Testbench conventions — CRITICAL

Always add #1 after every @(posedge clk):
```systemverilog
@(posedge clk); #1;  // ALWAYS
```

send task pattern:
```systemverilog
task automatic send(...);
    valid_in = 1;
    do begin @(posedge clk); #1; end while (!tready);
    valid_in = 0;
endtask
```

check task pattern:
```systemverilog
task automatic check(input signed [W:0] expected, input string label);
    do @(posedge clk); while (!valid_out);
    #1;
    if (result !== expected)
        $display("FAIL [%s]: got %0d expected %0d", label, result, expected);
    else
        $display("PASS [%s]: result = %0d", label, result);
endtask
```

Initial block always starts like this:
```systemverilog
initial begin
    $dumpfile("sim/waves.vcd");
    $dumpvars(0, module_name_tb);
    clk = 0; rst_n = 0; valid_in = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;
    @(posedge clk); #1;
    // tests follow
    $display("\nAll tests done.");
    $finish;
end
```

Makefile always uses .PHONY and tabs (not spaces):
```makefile
.PHONY: sim waves synth clean
sim:
	mkdir -p sim
	iverilog -g2012 -o sim/out rtl/module.sv tb/tb.sv && vvp sim/out
```

---

## Hard-won lessons from Rung 3 — read before writing Rung 4

### FSM timing — the DONE state is critical
The dot product FSM needed 3 states (IDLE/COMPUTE/DONE), not 2.
Without DONE, accum_valid fired before MAC outputs settled.
Rule: always add a DONE/OUTPUT state when registered outputs need
one extra cycle to settle after computation.

FSM accum_valid pattern that works:
```systemverilog
IDLE:    accum_valid <= 0; if (tvalid) state <= COMPUTE;
COMPUTE: accum_valid <= 1; state <= DONE;  // schedules high for DONE cycle
DONE:    accum_valid <= 0; state <= IDLE;  // drops after one cycle
```

### UVM on EDA Playground — setup rules
- Design files: paste ALL RTL into design.sv tab (mac_unit + dot_product)
  EDA Playground only compiles design.sv + testbench.sv by default
- run_test() MUST be called at time 0 — split initial blocks:
  ```systemverilog
  initial begin uvm_config_db::set(...); run_test("test_name"); end
  initial begin /* reset sequence */ end
  ```
- typedef class forward declaration needed when sequence references
  scoreboard before it's defined:
  ```systemverilog
  typedef class dot_product_scoreboard;  // at top of file
  ```
- uvm_analysis_port created in sequence constructor (not run_phase)
  to avoid ILLCRT "illegal to create component after build phase" error

### UVM driver timing bug — hold inputs until result ready
Driver MUST wait for accum_valid before calling item_done():
```systemverilog
// After handshake, hold inputs until result is captured
do @(vif.driver_cb); while (!vif.driver_cb.accum_valid);
seq_item_port.item_done();
```
Without this: driver loads next transaction's inputs before monitor
captures current result → monitor reads wrong a_flat/b_flat → wrong
expected value computed → all transactions fail.

Add accum_valid to driver clocking block:
```systemverilog
clocking driver_cb @(posedge clk);
    default input #1step output #1;
    output a_flat, b_flat, tvalid, tlast, rst_n;
    input  tready, accum_valid;  // ← must include accum_valid
endclocking
```

### Monitor capture pattern that works
Capture inputs AND output atomically when accum_valid fires:
```systemverilog
@(vif.monitor_cb);
if (vif.monitor_cb.accum_valid) begin
    item.a_flat = vif.monitor_cb.a_flat;
    item.b_flat = vif.monitor_cb.b_flat;
    item.actual = vif.monitor_cb.accum;
    ap.write(item);
end
```

### Scoreboard — simplest working pattern
Recompute expected from captured inputs in the scoreboard.
Avoids two-FIFO ordering problems entirely:
```systemverilog
mon_fifo.get(item);
item.compute_expected();  // recompute from item.a_flat/b_flat
if (item.actual !== item.expected) // compare
```

### Yosys — unpacked array ports fail
Yosys cannot synthesize unpacked array ports. Use flattened vectors:
```systemverilog
// WRONG for Yosys:
input logic [3:0] a [7:0]
// RIGHT:
input logic [31:0] a_flat  // DATA_WIDTH*VECTOR_LEN
// Unpack internally with generate block
```

### EDA Playground — UVM FIFO vs direct scoreboard
For simple single-transaction-at-a-time flows, avoid two-FIFO
scoreboard. Instead have the sequence hold a direct handle to the
scoreboard and call push_expected() directly:
```systemverilog
// In sequence:
seq.sb = env.scoreboard;
sb.push_expected(item.expected);
// In scoreboard:
logic signed [W:0] expected_q[$];
function void push_expected(logic signed [W:0] exp);
    expected_q.push_back(exp);
endfunction
```

---

## Hard-won lessons from Rung 4 RTL design

### Signed vs unsigned in port declarations
`logic [N:0]` is unsigned by default. Add `signed` keyword for any
port carrying a signed value. For gear_quantizer: data_in, int4_out,
sideband_out are signed; threshold, scale, abs_data_in are unsigned.
Getting this wrong causes silent bugs in comparison and arithmetic.

### Signed × unsigned multiply — always cast
When multiplying a signed signal by an unsigned one, SV silently treats
the signed operand as unsigned. Fix: zero-extend the unsigned operand
by 1 bit and cast to signed:
```systemverilog
mult_res = data_in * $signed({1'b0, scale});
```
Without this, negative data_in values give completely wrong products.

### Intermediate bit widths — compute the worst case
For an 8-bit signed × 4-bit unsigned multiply:
- worst case magnitude: abs(-128) × 15 = 1920
- needs signed 12-bit intermediate: logic signed [DATA_WIDTH+INT4_WIDTH-1:0]
- parameterize as [DATA_WIDTH+INT4_WIDTH-1:0] not hardcoded

### abs() in hardware — unsigned output avoids saturation
abs(-128) = 128, which overflows signed 8-bit but fits in unsigned 8-bit.
Declaring abs_data_in as `logic [DATA_WIDTH-1:0]` (no signed keyword)
means 8'b10000000 is read as 128, not -128. No saturation needed.
Compute as: `abs_data_in = data_in[MSB] ? -data_in : data_in;`

### Clip bounds — use localparam not hardcoded literals
```systemverilog
localparam signed [INT4_WIDTH-1:0] INT4_MAX =  (1 << (INT4_WIDTH-1)) - 1; // 7
localparam signed [INT4_WIDTH-1:0] INT4_MIN = -(1 << (INT4_WIDTH-1));      // -8
```
Then clip: `(val > INT4_MAX) ? INT4_MAX : (val < INT4_MIN) ? INT4_MIN : val[INT4_WIDTH-1:0]`

### valid_out must be unconditional in else branch
`valid_out <= valid_in` must sit directly in the `else` block, NOT
gated by `if (valid_in)`. If gated, valid_out holds high when
valid_in goes low (register retains last value). Put reset check
first, then valid_out assignment, then the valid_in gate:
```systemverilog
end else begin
    valid_out <= valid_in;   // unconditional — clears when input drops
    if (valid_in) begin
        // output muxing
    end
end
```

### Functional coverage plan for gear_quantizer
Coverage groups to implement in UVM testbench:
| Covergroup        | Bins                                              |
|-------------------|---------------------------------------------------|
| Input range       | negative / zero / positive                        |
| Outlier flag      | is_outlier=0 / is_outlier=1                       |
| Threshold boundary| abs < threshold / == threshold / > threshold      |
| Clip boundary     | int4_out at -8 / middle / at +7                   |
| scale             | 0 / mid / max(15)                                 |
| round_mode        | truncate(0) / round(1)                            |

---

## Reference files to read before writing Rung 4 code
- rung2-quantizer/rtl/quantizer.sv — quantization pipeline to reuse
- rung2-quantizer/tb/generate_vectors.py — Python co-sim pattern
- rung3-dot-product/tb/uvm/testbench.sv — working UVM template
- rung1-mac-unit/rtl/mac_unit.sv — MAC unit (not needed for Rung 4)

---

## End-of-session checklist — ALWAYS do this before user exits

At the end of every session, before the user closes Claude Code:
1. Update CLAUDE.md "Current status" section with what was completed
2. Add any new hard-won lessons to the relevant lessons section
3. Update "Next steps" in the relevant rung's status
4. Give the user the git commit command to run in their terminal

Git commit command template (user runs this themselves):
```bash
cd /home/ugunt/projects/ai-accelerator-verification && git add -p && git commit -m "rung4: <description of what was done>"
```

---

## Teaching style — IMPORTANT
This is a learning project. Follow these rules exactly:

1. ALWAYS quiz before showing code — ask a conceptual question and
   wait for the student to answer before revealing the implementation.

2. Build code incrementally — never paste a complete module at once.
   Walk through it section by section, explaining each part.

3. When the student writes code, review it and point out issues without
   immediately giving the fix. Ask "what do you think is wrong here?" first.

4. Explain the WHY behind every design decision, not just the what.
   Connect everything back to how real hardware works.

5. When the student answers a quiz correctly, acknowledge it and add
   one deeper insight they didn't mention.

6. When the student answers incorrectly, don't just correct them —
   trace through the reasoning to show where it went wrong.

7. Suggested quiz patterns:
   - "Before we write this, what do you think X does?"
   - "If we didn't have Y, what would go wrong?"
   - "What is the bit width of Z and why?"
   - "Trace through what happens cycle by cycle when..."
   - "Walk me through what this block of code does line by line"

8. Never write more than ~15 lines of code without stopping to explain
   or quiz.

9. After finishing each module, give a short summary of what was learned
   and how it connects to the next module.

10. When debugging, guide the student to add debug signals and reason
    through the output rather than immediately providing the fix.

---

## Internship targets
- Nvidia Hardware Verification Intern (applying August 2026)
- Apple Hardware Technologies Intern (applying August 2026)

## Relevant JD requirements
- SystemVerilog RTL design ✓
- Testbench creation ✓
- Python co-simulation ✓
- Synthesis Yosys + OpenLane ✓
- UVM ✓ (Rung 3 complete)
- Constrained random ✓ (Rung 3)
- Functional coverage — Rung 4
- AXI-Stream VIP ✓ (Rung 3)