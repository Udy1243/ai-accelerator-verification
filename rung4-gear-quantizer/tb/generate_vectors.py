import random
import subprocess
import struct


def golden_model(data_in, threshold, scale):

    if(abs(data_in) > threshold):
        is_outlier = 1
        int4_out = 0
        sideband_out = data_in

    else:
        is_outlier = 0
        sideband_out = 0
        product = int(data_in * scale)
        int4_out = max(min(product, 7), -8)

    return {'is_outlier': is_outlier, 'int4_out': int4_out, 'sideband_out': sideband_out}

def generate_vectors(num_vectors):
    with open('sim/vectors.txt', 'w') as f:
        for i in range(num_vectors):
            threshold = random.randint(0, 100)
            scale = random.randint(0, 15)
            data_in = random.randint(-128, 127)
            golden_output = golden_model(data_in, threshold, scale)
            f.write(f'{data_in} {threshold} {scale} {golden_output["is_outlier"]} {golden_output["int4_out"]} {golden_output["sideband_out"]}\n')

if __name__ == "__main__":
    import os
    os.makedirs("sim", exist_ok=True)
    generate_vectors(1000)
    print("Generated 1000 vectors → sim/vectors.txt")
    
