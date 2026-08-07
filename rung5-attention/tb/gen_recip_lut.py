"""
Generates the case-statement body for softmax.sv's get_recip() function --
a reciprocal LUT that replaces the runtime division
    raw = (exp_val_i * 256) / sum
with
    raw = (exp_val_i * 256) * get_recip(sum) >> RECIP_SHIFT

Runtime division by a variable synthesizes to a deep combinational array
divider that crashed OpenLane's ABC step (44284 gates for softmax.sv alone,
SIGABRT). Reciprocal-multiply replaces that divider with a table lookup
(cheap, same shape as the existing get_exp_val() LUT) plus one multiply.

K=27 and ceil() rounding (not round-to-nearest -- that has a nonzero floor
of mismatches no matter how large K gets, see tb/check_recip_lut.py) were
chosen because they're the smallest values that give exactly 0 mismatches
against true floor division across the full achievable domain: numerator
exp_val_i in [0,255], denominator sum in [255,2040]. sum's range comes from
softmax.sv's own structure: the row's own max score always contributes
exactly exp_val=255 (shifted=0 -> get_exp_val(0)=255), so sum >= 255; max
is all 8 terms tied at 255 (sum=2040).
"""

RECIP_SHIFT = 27
SUM_MIN = 255
SUM_MAX = 2040  # NUM_INPUTS * 255


def build_recip_table():
    return {s: -(-(1 << RECIP_SHIFT) // s) for s in range(SUM_MIN, SUM_MAX + 1)}  # ceil(2**K / s)


if __name__ == "__main__":
    table = build_recip_table()
    print(f"localparam int RECIP_SHIFT = {RECIP_SHIFT};")
    print(f"localparam int RECIP_WIDTH = {max(table.values()).bit_length()};")
    print()
    print("case (sum)")
    for s, recip in table.items():
        print(f"    {s}: get_recip = {max(table.values()).bit_length()}'d{recip};")
    print("    default: get_recip = 20'd0;")
    print("endcase")
