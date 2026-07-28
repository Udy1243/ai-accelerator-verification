import random
import os

from gen_exp_lut import build_exp_table

NUM_INPUTS = 8
INPUT_MIN = -1024
INPUT_MAX = 1023
LUT_SHIFT = 4  # must match RTL's LUT_SHIFT and gen_exp_lut.py's DIVISOR (2**LUT_SHIFT)

EXP_TABLE = build_exp_table()


def golden_model(scores):
    max_val = max(scores)

    exp_vals = []
    for s in scores:
        shifted = s - max_val          # always <= 0, since max_val is the max
        idx = (-shifted) >> LUT_SHIFT   # non-negative, so plain >> matches RTL's >>>
        exp_vals.append(EXP_TABLE[idx] if idx < len(EXP_TABLE) else 0)

    exp_sum = sum(exp_vals)

    weights = []
    for e in exp_vals:
        raw = (e * 256) // exp_sum
        weights.append(min(raw, 255))

    return weights


def generate_vectors(num_vectors):
    os.makedirs("sim", exist_ok=True)
    with open("sim/vectors.txt", "w") as f:
        for _ in range(num_vectors):
            scores = [random.randint(INPUT_MIN, INPUT_MAX) for _ in range(NUM_INPUTS)]
            weights = golden_model(scores)
            f.write(" ".join(str(s) for s in scores) + " " +
                     " ".join(str(w) for w in weights) + "\n")


if __name__ == "__main__":
    generate_vectors(1000)
    print("Generated 1000 vectors -> sim/vectors.txt")
