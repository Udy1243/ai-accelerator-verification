import random
import os

from generate_vectors import golden_model as softmax_golden_model

SEQ_LEN = 8
D_K = 16
DATA_WIDTH = 8
DATA_MIN = -(2 ** (DATA_WIDTH - 1))       # -128
DATA_MAX = 2 ** (DATA_WIDTH - 1) - 1      # 127


def dot(row_a, row_b):
    return sum(a * b for a, b in zip(row_a, row_b))


def attention_golden_model(q, k, v):
    # q, k, v: SEQ_LEN x D_K lists of ints, matching attention.sv exactly:
    # Q*K^T -> scale >>>2 -> softmax (reuses the already bit-exact
    # softmax golden_model) -> weights*V, rescale >>>8, clip.
    raw_scores = [[dot(q[i], k[j]) for j in range(SEQ_LEN)] for i in range(SEQ_LEN)]

    # Python's >> on a (possibly negative) int is a floor shift, matching
    # SV's >>> exactly -- same as the LUT_SHIFT floor-division lesson.
    scaled_scores = [[raw_scores[i][j] >> 2 for j in range(SEQ_LEN)] for i in range(SEQ_LEN)]

    weights = [softmax_golden_model(scaled_scores[i]) for i in range(SEQ_LEN)]

    out = []
    for i in range(SEQ_LEN):
        row_out = []
        for col in range(D_K):
            acc = sum(weights[i][m] * v[m][col] for m in range(SEQ_LEN))
            rescaled = acc >> 8
            rescaled = max(DATA_MIN, min(DATA_MAX, rescaled))
            row_out.append(rescaled)
        out.append(row_out)

    return out


def random_matrix():
    return [[random.randint(DATA_MIN, DATA_MAX) for _ in range(D_K)] for _ in range(SEQ_LEN)]


def generate_vectors(num_vectors):
    os.makedirs("sim", exist_ok=True)
    with open("sim/attention_vectors.txt", "w") as f:
        for _ in range(num_vectors):
            q = random_matrix()
            k = random_matrix()
            v = random_matrix()
            out = attention_golden_model(q, k, v)

            flat = lambda m: " ".join(str(x) for row in m for x in row)
            f.write(flat(q) + "\n")
            f.write(flat(k) + "\n")
            f.write(flat(v) + "\n")
            f.write(flat(out) + "\n")


if __name__ == "__main__":
    generate_vectors(500)
    print("Generated 500 vectors -> sim/attention_vectors.txt")
