import argparse
import numpy as np
import matplotlib.pyplot as plt
import os

# This script assumes that all the latency files
# we want to include have been produced.
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('folder')
    args = parser.parse_args()

    files = os.listdir(args.folder)

    files = [file for file in files if file.endswith('.dat')]

    delays = []
    with open('delays') as delay_file:
        for line in delay_file.readlines():
            delays.append(int(line))

    measured_delays = []
    for delay in delays:
        this_measured_delays = []

        # Get every single run for this delay.
        files_with_delay = \
            [file for file in files
                if file.startswith(str(delay) + '_latency_differences')]
        # Now, for each file, put all the delays together.
        for file in files_with_delay:
            with open(file) as f:
                this_measured_delays.append(f.readlines()[0].splilt(','))
                for i in range(len(this_measured_delays)):
                    this_measured_delays[i] = float(this_measured_delays[i])
        # Keep track of all of the delays.
        measured_delays.append(this_measured_delays)

    # Finally, plot those.
    y_data = []
    y_errors = []

    for measurements in measured_delays:
        y_data.append(np.median(measurements))
        y_errors.append((min(measurements), max(measurements)))

    plt.title("Difference between Requested Delay and Measured Delay (NRG)")
    plt.xlabel("Requested Delay (log ns)")
    plt.ylabel("Difference between requested and measured delay (log ns)")

    ax = plt.gca()
    ax.set_yscale('log')
    ax.set_xscale('log')
    plt.errorbar(delays, y_data, yerr=y_errors, fmt='o')
    plt.savefig('nrg_requested_delay_vs_measured_delay.eps')
