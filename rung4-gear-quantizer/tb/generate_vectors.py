import random
import subprocess
import struct


def golden_model(data_in, threshold, scale, round_mode):

    if(abs(data_in) > threshold):
        is_outlier = 1
        int4_out = 0
        sideband_out = data_in

    else:
        is_outlier = 0
        sideband_out = 0
        # scale is a fixed-point fraction scale/16 (Q0.4): product >> 4 is the
        # integer part, product % 16 is the dropped nibble. Python's // and %
        # are floor-based, matching SystemVerilog's arithmetic right shift.
        product = data_in * scale
        shifted = product // 16
        remainder = product % 16
        rounded = shifted + 1 if (round_mode and remainder >= 8) else shifted
        int4_out = max(min(rounded, 7), -8)

    return {'is_outlier': is_outlier, 'int4_out': int4_out, 'sideband_out': sideband_out}

def generate_vectors(num_vectors):
    with open('sim/vectors.txt', 'w') as f:
        for i in range(num_vectors):
            threshold = random.randint(0, 100)
            scale = random.randint(0, 15)
            data_in = random.randint(-128, 127)
            round_mode = random.randint(0, 1)
            golden_output = golden_model(data_in, threshold, scale, round_mode)
            f.write(f'{data_in} {threshold} {scale} {round_mode} '
                    f'{golden_output["is_outlier"]} {golden_output["int4_out"]} {golden_output["sideband_out"]}\n')

if __name__ == "__main__":
    import os
    os.makedirs("sim", exist_ok=True)
    generate_vectors(1000)
    print("Generated 1000 vectors → sim/vectors.txt")
    
