# Rung 5 — Attention Score Unit

Scaled dot-product attention (`Q × Kᵀ → scale → softmax → × V`) in SystemVerilog,
verified with directed testbenches and Python co-simulation, and synthesized
through the full RTL-to-GDS flow on SKY130 via OpenLane.

## What it does

This is the core computation inside every transformer layer — the same
attention mechanism used in every modern LLM:

```
scores  = Q × Kᵀ                    # [8,16] × [16,8] -> [8,8] (d_k cancels out)
scaled  = scores >>> 2              # ÷ √d_k = ÷4, keeps score differences inside
                                     # softmax's LUT decay range
weights = softmax(scaled)           # row-wise, numerically stable (subtract max first)
output  = weights × V               # [8,8] × [8,16] -> [8,16]
```

Two modules:

- **`softmax.sv`** — an 8-input, numerically-stable softmax. Subtracts the
  row max before exponentiating (standard softmax stability trick), looks up
  `exp()` via a case-statement LUT (no floating point, no runtime division),
  and normalizes by a reciprocal-multiply LUT instead of a real divider.
- **`attention.sv`** — the top-level FSM that wires `softmax` together with
  two reused instances of Rung 3's `dot_product` (once for `Q·Kᵀ`, once for
  `weights·V`) to compute full attention over an 8-token, 16-dim sequence.

## Design

### softmax.sv

| Parameter | Default | Description |
|-----------|---------|-------------|
| `NUM_INPUTS` | 8 | Number of scores per row |
| `INPUT_WIDTH` | 11 | Bits per input score (signed) |
| `OUTPUT_WIDTH` | 8 | Bits per output weight (Q0.8 fixed point) |

| Port | Direction | Width | Description |
|------|-----------|-------|--------------|
| `clk`, `rst_n` | in | 1 | Clock, active-low reset |
| `inputs` | in | `NUM_INPUTS*INPUT_WIDTH` | Flattened signed scores |
| `valid_in` | in | 1 | Input valid |
| `valid_out` | out | 1 | Output valid (1-cycle latency) |
| `weights_flat` | out | `NUM_INPUTS*OUTPUT_WIDTH` | Flattened Q0.8 weights, sum ≤ 256 |

5-stage combinational pipeline (max → subtract → exp LUT → normalize →
register): find row max, subtract it from every score, look up `exp()` per
score via a case-statement LUT (input pre-scaled `>>> 4` to spread the decay
curve across ~100 of 256 table entries instead of hitting zero after 7),
sum and normalize via reciprocal-multiply, clip to 255 (the dominant-term
case can hit exactly 256, one too many for 8 bits), register the output.

### attention.sv

| Parameter | Default | Description |
|-----------|---------|--------------|
| `SEQ_LEN` | 8 | Tokens (rows) in Q/K/V |
| `D_K` | 16 | Embedding depth (cols) in Q/K/V |
| `DATA_WIDTH` | 8 | Bits per Q/K/V element (signed) |
| `ACCUM_WIDTH` | 20 | Dot-product accumulator width |

| Port | Direction | Width | Description |
|------|-----------|-------|--------------|
| `clk`, `rst_n` | in | 1 | Clock, active-low reset |
| `row_data` | in | `D_K*DATA_WIDTH` (128) | One Q/K/V row |
| `row_addr` | in | 3 | Row index (0-7) |
| `matrix_sel` | in | 2 | 00=Q, 01=K, 10=V |
| `load_valid` | in | 1 | One-cycle load strobe |
| `start` | in | 1 | Begin compute once Q/K/V are loaded |
| `out_row_data` | out | `D_K*DATA_WIDTH` (128, signed) | One output row |
| `out_valid` | out | 1 | Output row valid |
| `out_tlast` | out | 1 | High on the last (row 7) output |

**267 pins total.** Q/K/V load one row per cycle over a shared bus (24 cycles
for all three matrices) instead of exposing the full matrices as combinational
chip pins — an earlier flat-bus version needed 4,100 pins and couldn't fit
through OpenLane's IO placer. Output streams back the same way, one row per
cycle, using the same valid+last shape as `dot_product`'s own AXI-Stream
interface.

6-state FSM: `IDLE → SCORE → SCALE → SOFTMAX_ST → WEIGHTED_SUM → OUTPUT_ST → IDLE`.
`SCORE` and `WEIGHTED_SUM` each drive a `dot_product` instance back-to-back
(64 calls and 128 calls respectively) gated by its own `tready`; `SOFTMAX_ST`
feeds `softmax` one row per cycle exploiting its fixed 1-cycle latency and
lack of backpressure.

## Verification

### Directed tests (iverilog)

**softmax.sv** — 5/5 passing (`tb/softmax_tb.sv`):

```
PASS [normal_spread_max_at_0]: max weight at idx 0 (217), sum = 252
PASS [dominant_score_clips_255]: max weight at idx 0 (255), sum = 255
PASS [rail_extremes]: max weight at idx 0 (204), sum = 254
PASS [rail_extremes_shifted]: shifted[1] = -2047 (12-bit headroom holds)
PASS [near_uniform_even_split]: all weights = 32, sum = 256
```

**attention.sv** — 5/5 passing (`tb/attention_tb.sv`):

```
PASS [Test 1: all-zero]: all 128 elements = 0
PASS [Test 2: all-ones]: all 128 elements = 1
PASS [Test 3: dominant row, negative V]: all 128 elements = -50
PASS [Test 4a: back-to-back #1]: all 128 elements = 1
PASS [Test 4b: back-to-back #2]: all 128 elements = 1
```

Test 4 (back-to-back transactions) caught a real bug: `out_row`/`out_col`
(the `WEIGHTED_SUM` loop counters) were only reset on `!rst_n`, not at the
state transition into `WEIGHTED_SUM` like the other sweep counters — a
second transaction in the same simulation would start with stale terminal
indices from the first run and write only 1 of 128 output elements. Fixed
by resetting both counters at the `SOFTMAX_ST → WEIGHTED_SUM` transition.
Invisible on any single isolated run (a fresh reset already zeroes them by
coincidence) — only a back-to-back test surfaces it.

### Python co-simulation

```
Co-sim done: 1000/1000 passed        (softmax, tb/softmax_cosim_tb.sv)
Attention co-sim done: 500/500 passed (attention, tb/attention_cosim_tb.sv)
```

Both bit-exact (0 tolerance), not tolerance-based. The softmax golden model
replicates the exact same LUT + reciprocal-multiply the RTL uses (imported
from the same generator scripts, one source of truth) rather than comparing
against true floating-point softmax — a tolerance check couldn't distinguish
"expected LUT approximation error" from "an actual RTL bug." The attention
golden model reuses the softmax golden model directly and is pure fixed-point
integer math for the other two stages, so it's bit-exact too.

**Caveat on realism:** for uncorrelated random Q/K (what the co-sim
generates), ~64% of attention rows fully collapse to a hard argmax — the
runner-up score's distance from the max exceeds the softmax LUT's ~1584
decay threshold. This doesn't affect correctness (still bit-exact against
the same LUT the RTL implements) but real trained embeddings are typically
far more correlated than uniform noise; this co-sim proves the hardware
matches its own golden model, not that the LUT gives smooth non-argmax
softmax on realistic data.

## OpenLane SKY130 Results

| Metric | Value |
|--------|-------|
| Core area | 1,344,254 µm² (~1.34 mm²) |
| Logic cells (post-synthesis) | 51,830 |
| Core utilization | 39% |
| Setup slack | +3.02 ns @ 40 ns (25 MHz) clock |
| Hold slack | +0.29 ns |
| Target / achieved frequency | 25 MHz |
| Total power (typical) | ~0.44 mW (0.12 mW internal + 0.324 mW switching) |
| Detailed routing (tritonRoute) violations | 0 |
| DRC violations (post-GDS) | 0 |
| LVS | Clean match, 0 errors |
| GDS XOR (Magic vs KLayout) | No differences |
| Antenna violations | 38 pin + 38 net |

**Two honest caveats, unlike every prior rung's "0 DRC/antenna/LVS violations":**

1. **Target frequency dropped from 40 MHz to 25 MHz.** OpenLane's
   `GLB_RESIZER_TIMING_OPTIMIZATIONS` pass — the timing-driven buffering step
   that would close 40 MHz timing — segfaults on this specific netlist
   (`RSZ-0073`: "driver pin not found in global routes", root cause not
   isolated beyond "disabling the pass avoids it"). Disabling it was the only
   way to get a clean signoff; the tradeoff is losing that buffering, so the
   design was retargeted to the 25 MHz it comfortably meets instead
   (+3.02 ns slack).
2. **Antenna violations aren't fully zero** (38 pin + 38 net). Enabling
   `RUN_HEURISTIC_DIODE_INSERTION` (off by default) cut this from 402/263 to
   38/38, but didn't finish the job. A stronger diode strategy or more
   `GRT_MAX_DIODE_INS_ITERS` iterations would be the next thing to try if a
   fully-clean antenna signoff is required.

**Config tuning history** (6 iterations — routing congestion, a resizer
segfault, a timing miss, and an antenna gap, each root-caused and fixed in
turn) is documented in full in the project's top-level `CLAUDE.md` under
"Hard-won lessons from Rung 5 OpenLane synthesis."

**Final `openlane/config.json`:**
```json
{
  "FP_CORE_UTIL": 40,
  "PL_TARGET_DENSITY": 0.45,
  "ROUTING_CORES": 8,
  "GRT_ADJUSTMENT": 0.2,
  "CLOCK_PERIOD": 40.0,
  "GLB_RESIZER_TIMING_OPTIMIZATIONS": 0,
  "RUN_HEURISTIC_DIODE_INSERTION": 1
}
```

## How to Run

```bash
# softmax directed tests
make sim

# softmax co-simulation (generates 1000 vectors, runs SV testbench)
make cosim

# attention.sv directed tests
make sim_attn

# attention.sv co-simulation (generates 500 vectors, runs full pipeline)
make cosim_attn

# Yosys synthesis stats (softmax only)
make synth

# Open waveforms
make waves

# OpenLane SKY130 synthesis (from ~/OpenLane, requires Docker)
cd ~/OpenLane && make mount
# inside the container:
./flow.tcl -design /home/ugunt/projects/ai-accelerator-verification/rung5-attention/openlane -overwrite
```

## Design Notes

- Runtime division (`exp_val*256/exp_sum` in `softmax.sv`) crashed OpenLane's
  ABC step outright (SIGABRT) — division synthesizes to a deep sequential
  array divider (depth ~O(N), gates ~O(N²)) that structural hashing can't
  simplify. Replaced with `(numerator * get_recip(sum)) >> RECIP_SHIFT`, a
  case-statement reciprocal LUT (`tb/gen_recip_lut.py`) proven bit-exact
  against true floor division across the full achievable domain
  (`tb/check_recip_lut.py`) — requires *ceiling*-rounded reciprocals, not
  round-to-nearest, which plateaus at a nonzero error floor no matter how
  much precision is added.
- `attention.sv`'s original interface flattened Q/K/V/out into four
  1024-bit buses (4,100 pins total) — exceeded OpenLane's IO placer capacity
  outright. Redesigned to the 267-pin shared load-bus interface described
  above — the standard way real accelerators load large matrices (a narrow
  streamed port, not raw parallel chip pins), since wires/pins are
  physically expensive and clock cycles are nearly free by comparison.
- `weights[]` from `softmax` are unsigned Q0.8 (0-255); feeding them into
  the signed `dot_product` datapath for `weights·V` needs zero-extension to
  9 bits, not just a signed cast — an 8-bit signed slot can't represent 200
  without misreading it as -56, and there's no way to add a sign bit without
  adding a bit.
- The `weights·V` sum carries an implicit ×256 from the Q0.8 format and
  needs `>>> 8` to rescale back to `V`'s original units before a defensive
  clip to `DATA_WIDTH` — same clip-bound pattern as Rung 4's `INT4_MAX`/`INT4_MIN`.
- `sm_cycle` (the softmax-feeding counter in `SOFTMAX_ST`) needs 4 bits, not
  3 — it must represent the value 8 itself (a fencepost case: "fed/captured
  all 8 rows"), and 3 bits would silently wrap to 0 and hang the FSM forever.

## Files

```
rtl/softmax.sv                     — softmax RTL (5-stage pipeline)
rtl/attention.sv                   — top-level attention FSM
tb/softmax_tb.sv                   — softmax directed testbench (5 tests)
tb/attention_tb.sv                 — attention directed testbench (5 tests)
tb/softmax_cosim_tb.sv             — softmax co-sim (reads sim/vectors.txt)
tb/attention_cosim_tb.sv           — attention co-sim (reads sim/attention_vectors.txt)
tb/generate_vectors.py             — softmax golden model + vector generator
tb/generate_attention_vectors.py   — full 3-stage pipeline golden model
tb/gen_exp_lut.py                  — generates softmax's exp() LUT case statement
tb/gen_recip_lut.py                — generates softmax's reciprocal-multiply LUT
tb/check_recip_lut.py              — brute-force proof the reciprocal LUT is bit-exact
openlane/config.json               — OpenLane SKY130 synthesis config
Makefile                           — sim / sim_attn / cosim / cosim_attn / synth / waves targets
```

## Context

Rung 5 of a five-rung AI accelerator verification project. Attention is the
mechanism that makes transformers "transformers" — directly relevant to LLM
inference acceleration hardware, the throughline connecting every rung of
this portfolio (MAC → quantizer → dot product → outlier-aware quantizer →
attention). UVM testbench + functional coverage for `attention.sv` is the
one item not yet started; it will need to account for the load-bus interface
rather than the single-cycle flat-bus shape used in Rung 3/4's UVM environments.
