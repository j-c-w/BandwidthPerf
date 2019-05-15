from decimal import Decimal
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
    delays_index = 0
    print delays
    while delays_index < len(delays):
        this_measured_delays = []

        # Get every single run for this delay.
        files_with_delay = \
            [file for file in files
                if file.startswith(str(delays[delays_index]) + '_latency_differences')]
        # Check if any of the files with this added delay
        # were processed.  The HPT is not perfect at captuing,
        # if some packets were dropped (either by  the HPT
        # or by the NRG, then the data file can't be computed.
        if len(files_with_delay) == 0:
            # We obviously don't want to plot anything for this data point.
            print " No valid data recorded for latency ", str(delays[delays_index])
            del delays[delays_index]
            continue

        # Now, for each file, put all the delays together.
        for file in files_with_delay:
            with open(args.folder + '/' + file) as f:
                this_file_delays = f.readlines()[0].split(',')
                for i in range(len(this_file_delays)):
                    this_file_delays[i] = Decimal(this_file_delays[i])
                this_measured_delays += this_file_delays
        # Keep track of all of the delays.
        measured_delays.append(this_measured_delays)
        print "Extracted Delays for requested delay", delays[delays_index]
        delays_index += 1

    # Also produce graphs for each delay with the CDF
    # for that delay.
    if delays[0] == 0:
        zero_delay = np.median(measured_delays[0])
    else:
        zero_delay = Decimal(0.0)

    for index in range(len(delays)):
        this_delays = [float(x - zero_delay - delays[index]) for x in measured_delays[index]]
        plt.clf()
        plt.title("Distribution of introduced latencies by the \n NRG with requested latency of %s ns" % delays[index])
        plt.xlabel("Measured Delay (ns)")
        plt.ylabel("CDF")
        plt.xticks(rotation=90)
        ax = plt.gca()
        xmin = float(min(this_delays))
        xmax = float(max(this_delays))
        ax.set_xticks(np.arange(xmin, xmax, (xmax - xmin)/20.0))
        bins = np.append(np.linspace(xmin, xmax, 1000), np.inf)
        ax.set_axisbelow(True)
        plt.grid()
        plt.hist(this_delays, cumulative=True, bins=bins, normed=True, histtype='step')
        plt.tight_layout()
        plt.savefig('delay_distribution_for_latency_' + str(delays[index]) + '.eps')

    for i in range(len(measured_delays)):
        for j in range(len(measured_delays[i])):
            measured_delays[i][j] = float(measured_delays[i][j])

    # Finally, plot those.
    y_data = []
    y_errors_min = []
    y_errors_max = []

    for i in range(len(measured_delays)):
        measurements = measured_delays[i]
        requested = delays[i]
        graph_value = np.median(measurements) - requested
        y_data.append(graph_value)
        low99th, high99th = (min(measurements), max(measurements))
        y_errors_min.append(graph_value - (low99th - requested))
        y_errors_max.append((high99th - requested) - graph_value)

    plt.clf()
    plt.title("Difference between Requested Delay and Measured Delay (NRG)")
    plt.xlabel("Requested Delay (ns)")
    plt.ylabel("Difference between requested and measured delay (ns)")

    ax = plt.gca()
    ax.set_xscale('log')
    ax.set_yscale('log')
    plt.grid()
    plt.errorbar(delays, y_data, yerr=(y_errors_min, y_errors_max))
    plt.savefig('nrg_requested_delay_vs_measured_delay.eps')

    # Plot the same thing, but with the offset of the latency introduced at 0.
    if delays[0] == 0:
        y_data = []
        y_errors_min = []
        y_errors_max = []

        zero_min_delay = min(measured_delays[0])
        print zero_min_delay

        print measured_delays
        for i in range(len(measured_delays)):
            measurements = measured_delays[i]
            requested = delays[i]
            print requested
            graph_value = np.median(measurements) - requested - zero_min_delay
            y_data.append(graph_value)
            low99th, high99th = (min(measurements), max(measurements))
            y_errors_min.append(graph_value - (low99th - requested - zero_min_delay))
            y_errors_max.append((high99th - requested - zero_min_delay) - graph_value)

        plt.clf()
        plt.title("Difference between Requested Delay and Added Delay (NRG)")
        plt.xlabel("Requested Delay (ns)")
        plt.ylabel("Difference between requested and measured delay (ns)")

        plt.errorbar(delays, y_data, yerr=(y_errors_min, y_errors_max))
        ax = plt.gca()
        ax.set_xscale('log')
        plt.grid()
        plt.savefig('nrg_requested_delay_vs_added_delay.eps')
