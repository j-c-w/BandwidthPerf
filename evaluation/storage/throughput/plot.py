import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--input', nargs=2, action='append', dest='input', default=[])

    args = parser.parse_args()

    bars = []
    min_errors = []
    max_errors = []
    labels = []

    for (test_name, filename) in args.input:
        with open(filename) as f:
            results = f.readlines()
            bps = []
            for line in results:
                bytes = int(line.split(' ')[0]) / 1000000000
                time = float(line.split(' ')[1])

                bits = bytes * 8
                bps.append(float(bits) / time)
            bar_value = np.median(bps)
            bars.append(bar_value)
            min_errors.append(bar_value - min(bps))
            max_errors.append(max(bps) - bar_value)
            labels.append(test_name)
    plt.bar(labels, bars, width=0.8, yerr=(min_errors, max_errors))
    plt.ylabel("Gbps")
    ax = plt.gca()
    ax.set_axisbelow(True)
    plt.grid()
    plt.savefig("storage_throughput.eps")
