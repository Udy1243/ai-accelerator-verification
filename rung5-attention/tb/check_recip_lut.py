"""
Brute-force check: does replacing softmax.sv's runtime division
    raw = (exp_val_i * 256) / sum
with a reciprocal-multiply
    raw = (exp_val_i * 256) * recip[sum] >> K      where recip[s] = round(2**K / s)
ever produce a different post-clip weight than the true division, for
every numerator/denominator combination the hardware can actually see?

exp_val_i range: full 0-255 (superset of what get_exp_val() can actually
output, checked for safety).
sum range: [255, 2040] -- exp_sum's true achievable range. At least one
of the 8 terms is always the row's own max score (shifted=0), which
get_exp_val() always maps to exactly 255, so sum can never be below 255.
Max is all 8 terms tied at 255 (2040). See softmax.sv Stage 4 comment.
"""

def true_weight(exp_val_i, s):
    raw = (exp_val_i * 256) // s
    return min(raw, 255)

def approx_weight(exp_val_i, s, K):
    recip = round((1 << K) / s)
    raw = (exp_val_i * 256 * recip) >> K
    return min(raw, 255)

def check(K):
    mismatches = []
    for s in range(255, 2041):
        for e in range(256):
            t = true_weight(e, s)
            a = approx_weight(e, s, K)
            if t != a:
                mismatches.append((e, s, t, a))
    return mismatches

if __name__ == "__main__":
    for K in [16, 17, 18, 19, 20]:
        mismatches = check(K)
        print(f"K={K}: {len(mismatches)} mismatches out of {1786*256}")
        if mismatches:
            print(f"  example: {mismatches[0]}")
        else:
            print(f"  -> bit-exact for all (exp_val_i, sum) combinations")
            break
