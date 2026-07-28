import math

NUM_ENTRIES = 256
SCALE = 255
DIVISOR = 16  # RTL implements this as a >>> 4 shift, must stay a power of 2

vals = [round(SCALE * math.exp(-n / DIVISOR)) for n in range(NUM_ENTRIES)]
vals = [max(0, min(255, v)) for v in vals]  # sanity clamp, should never trigger

# iverilog doesn't support '{...} array-literal initializers on unpacked
# arrays (localparam or otherwise), so the LUT is emitted as a case
# statement instead. default: covers both "genuinely decayed to zero"
# indices and any index that falls outside this table entirely.
print("case (idx)")
for n, v in enumerate(vals):
    if v == 0:
        continue
    print(f"    {n}: get_exp_val = 8'd{v};")
print("    default: get_exp_val = 8'd0;")
print("endcase")
