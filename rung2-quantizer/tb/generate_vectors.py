import numpy as np

NUM_VECTORS = 1000
OUTPUT_FILE = "tb/golden.txt"

# INT8 range
MAX_VAL = 127
MIN_VAL = -128

rng = np.random.default_rng(seed=42)

# 700 vectors with large values (will mostly saturate)
data_in_large    = rng.integers(-32768, 32767, size=700, dtype=np.int16)
scale_large      = rng.integers(1,      255,   size=700, dtype=np.uint8)
round_mode_large = rng.integers(0,      2,     size=700, dtype=np.uint8)

# 300 vectors with small values (won't saturate)
data_in_small    = rng.integers(-10, 10,  size=300, dtype=np.int16)
scale_small      = rng.integers(1,   10,  size=300, dtype=np.uint8)
round_mode_small = rng.integers(0,   2,   size=300, dtype=np.uint8)

# combine both
data_in    = np.concatenate([data_in_large,    data_in_small])
scale      = np.concatenate([scale_large,      scale_small])
round_mode = np.concatenate([round_mode_large, round_mode_small])
expected_out      = np.zeros(NUM_VECTORS, dtype=np.int32)
expected_overflow = np.zeros(NUM_VECTORS, dtype=np.uint8)

for i in range(NUM_VECTORS):
    scaled = int(data_in[i]) * int(scale[i])
    
    if round_mode[i] == 1:
        scaled += 1
    
    if scaled > MAX_VAL or scaled < MIN_VAL:
        expected_overflow[i] = 1
    else:
        expected_overflow[i] = 0
    
    expected_out[i] = np.clip(scaled, MIN_VAL, MAX_VAL)

with open(OUTPUT_FILE, "w") as f:
    for i in range(NUM_VECTORS):
        f.write(f"{data_in[i]} {scale[i]} {round_mode[i]} {expected_out[i]} {expected_overflow[i]}\n")

print(f"Generated {NUM_VECTORS} vectors -> {OUTPUT_FILE}")