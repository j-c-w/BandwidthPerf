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
                    this_file_delays[i] = Decimal(this_file_delays[i]) * Decimal(1000000000.0)
                this_measured_delays += this_file_delays
        # Keep track of all of the delays.
        measured_delays.append(this_measured_delays)
        print "Extracted Delays for requested delay", delays[delays_index]
        delays_index += 1

    # Also produce graphs for each delay with the CDF
    # for that delay.
    for index in range(len(delays)):
        plt.clf()
        plt.title("Distribution of introduced latencies by the \n NRG with requested latency of %s ns" % delays[index])
        plt.xlabel("Measured Delay")
        plt.ylabel("CDF")
        plt.xticks(rotation=90)
        ax = plt.gca()
        xmin = float(min(measured_delays[index]))
        xmax = float(max(measured_delays[index]))
        ax.set_xticks(np.arange(xmin, xmax, (xmax - xmin)/20.0))
        bins = np.append(np.linspace(xmin, xmax, 1000), np.inf)
        ax.set_axisbelow(True)
        plt.grid()
        plt.hist([float(x) for x in measured_delays[index]], cumulative=True, bins=bins, normed=True, histtype='step')
        plt.tight_layout()
        plt.savefig('delay_distribution_for_latency_' + str(delays[index]) + '.eps')

    # For the plot with all of these, we want to look at the differences
    # between the requested and the real amount.
    for i in range(len(delays)):
        measurements = measured_delays[i]
        delay = Decimal(delays[i])
        for j in range(len(measurements)):
            measurements[j] -= delay

    for i in range(len(measured_delays)):
        for j in range(len(measured_delays[i])):
            measured_delays[i][j] = float(measured_delays[i][j])

    # Finally, plot those.
    y_data = []
    y_errors_min = []
    y_errors_max = []

    for measurements in measured_delays:
        graph_value = np.median(measurements)
        y_data.append(graph_value)
        print min(measurements)
        print max(measurements)
        y_errors_min.append(graph_value - min(measurements))
        y_errors_max.append(max(measurements) - graph_value)
    print len(delays)
    print len(y_data)

    plt.clf()
    plt.title("Difference between Requested Delay and Measured Delay (NRG)")
    plt.xlabel("Requested Delay (log ns)")
    plt.ylabel("Difference between requested and measured delay (log ns)")

    ax = plt.gca()
    ax.set_yscale('log')
    ax.set_xscale('log')
    plt.errorbar(delays, y_data, yerr=(y_errors_min, y_errors_max), fmt='o')
    plt.savefig('nrg_requested_delay_vs_measured_delay.eps')

    # Plot the same thing, but with the offset of the latency introduced at 0.
    if delays[0] == 0:
        y_data = []
        y_errors_min = []
        y_errors_max = []

        zero_min_delay = min(measured_delays[0])

        for measurements in measured_delays:
            graph_value = np.median(measurements)
            y_data.append(graph_value - zero_min_delay)
            print min(measurements)
            print max(measurements)
            y_errors_min.append(graph_value - min(measurements) - zero_min_delay)
            y_errors_max.append(max(measurements) - (graph_value - zero_min_delay))
        print len(delays)
        print len(y_data)

        plt.clf()
        plt.title("Difference between Requested Delay and Added Delay (NRG)")
        plt.xlabel("Requested Delay (log ns)")
        plt.ylabel("Difference between requested and measured delay (log ns)")

        ax = plt.gca()
        ax.set_yscale('log')
        ax.set_xscale('log')
        plt.errorbar(delays, y_data, yerr=(y_errors_min, y_errors_max), fmt='o')
        plt.savefig('nrg_requested_delay_vs_added_delay.eps')
