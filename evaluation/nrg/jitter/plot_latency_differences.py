from decimal import Decimal
import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import os
import sys
sys.path.insert(0, '/root/jcw78/process_pcap_traces/')
import graph_utils

# This script assumes that all the latency files
# we want to include have been produced.
if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument('folder')
    parser.add_argument('--groups', action='append', default=[], nargs='+', help='Draw the latencies of multiple jitters on a single graph.', dest='groups')
    args = parser.parse_args()

    files = os.listdir(args.folder)

    files = [file for file in files if file.endswith('.dat')]

    jitters = []
    with open('jitter') as jitter_file:
        for line in jitter_file.readlines():
            jitters.append(int(line))

    measured_jitters = []
    jitters_index = 0
    while jitters_index < len(jitters):
        this_measured_jitters = []

        # Get every single run for this jitter.
        files_with_jitter = \
            [file for file in files
                if file.startswith(str(jitters[jitters_index]) + '_latency_differences')]
        # Check if any of the files with this added jitter
        # were processed.  The HPT is not perfect at captuing,
        # if some packets were dropped (either by  the HPT
        # or by the NRG, then the data file can't be computed.
        if len(files_with_jitter) == 0:
            # We obviously don't want to plot anything for this data point.
            print " No valid data recorded for latency ", str(jitters[jitters_index])
            del jitters[jitters_index]
            continue

        # Now, for each file, put all the jitters together.
        for file in files_with_jitter:
            with open(args.folder + '/' + file) as f:
                this_file_jitters = f.readlines()[0].split(',')
                for i in range(len(this_file_jitters)):
                    this_file_jitters[i] = Decimal(this_file_jitters[i])
                this_measured_jitters += this_file_jitters
        # Keep track of all of the jitters.
        measured_jitters.append(this_measured_jitters)
        print "Loaded jitters for requested jitter", jitters[jitters_index]
        jitters_index += 1

    # Also produce graphs for each jitter with the CDF
    # for that jitter.
    if jitters[0] == 0:
        zero_jitter = np.median(measured_jitters[0])
    else:
        zero_jitter = Decimal(0.0)

    for index in range(len(jitters)):
        this_jitters = [float(x - zero_jitter) for x in measured_jitters[index]]
        plt.clf()
        plt.xlabel("Difference in jitter (ns)")
        plt.ylabel("CDF")
        plt.xticks(rotation=90)
        ax = plt.gca()
        xmin = float(min(this_jitters))
        xmax = float(max(this_jitters))
        ax.set_xticks(np.arange(xmin, xmax, (xmax - xmin)/20.0))
        bins = np.append(np.linspace(xmin, xmax, 1000), np.inf)
        ax.set_axisbelow(True)
        plt.grid()
        plt.hist(this_jitters, cumulative=True, bins=bins, normed=True, histtype='step')
        plt.tight_layout()
        graph_utils.set_yax_max_one()
        plt.savefig('jitter_distribution_for_latency_' + str(jitters[index]) + '.eps')

    for group in args.groups:
        jitters_in_group = [int(x) for x in group]
        measured_jitters_in_group = []
        overall_min = None
        overall_max = None

        for jitter in jitters_in_group:
            index = jitters.index(jitter)
            this_jitters = [float(x - zero_jitter - jitters[index]) for x in measured_jitters[index]]
            measured_jitters_in_group.append(this_jitters)

            this_max = max(this_jitters)
            this_min = min(this_jitters)
            if overall_min:
                overall_min = min(overall_min, this_min)
                overall_max = max(overall_max, this_max)
            else:
                overall_min = this_min
                overall_max = this_max

        plt.clf()
        plt.xlabel("Difference in Delay (ns)")
        plt.ylabel("CDF")
        plt.xticks(rotation=90)
        ax = plt.gca()
        xmin = float(overall_min)
        xmax = float(overall_max)
        ax.set_xticks(np.arange(xmin, xmax, (xmax - xmin)/20.0))
        bins = np.append(np.linspace(xmin, xmax, 1000), np.inf)
        ax.set_axisbelow(True)
        plt.grid()
        for index in range(len(measured_jitters_in_group)):
            this_jitters = measured_jitters_in_group[index]
            this_label = group[index] + ' ns'

            plt.hist(this_jitters, cumulative=True, bins=bins, normed=True, histtype='step', label=this_label)
        plt.tight_layout()
        graph_utils.set_yax_max_one()
        graph_utils.legend_bottom_right()
        plt.savefig('jitter_distribution_for_latencies_' + '_'.join(group) + '.eps')

    for i in range(len(measured_jitters)):
        for j in range(len(measured_jitters[i])):
            measured_jitters[i][j] = float(measured_jitters[i][j])

    # Finally, plot those.
    y_data = []
    y_errors_min = []
    y_errors_max = []

    for i in range(len(measured_jitters)):
        measurements = measured_jitters[i]
        requested = jitters[i]
        graph_value = np.median(measurements)
        y_data.append(graph_value)
        low99th, high99th = (min(measurements), max(measurements))
        y_errors_min.append(graph_value - (low99th))
        y_errors_max.append((high99th) - graph_value)

    plt.clf()
    plt.xlabel("Requested Jitter (ns)")
    plt.ylabel("Difference in Delay (ns)")

    ax = plt.gca()
    ax.set_xscale('log')
    ax.set_yscale('log')
    errorplot = plt.errorbar(jitters, y_data, yerr=(y_errors_min, y_errors_max))
    errorplot[-1][0].set_linestyle('--')
    graph_utils.set_ticks()
    plt.savefig('nrg_requested_jitter_vs_measured_jitter.eps')

    # Plot the same thing, but with the offset of the latency introduced at 0.
    if jitters[0] == 0:
        y_data = []
        y_errors_min = []
        y_errors_max = []

        zero_min_jitter = min(measured_jitters[0])
        print zero_min_jitter

        for i in range(len(measured_jitters)):
            measurements = measured_jitters[i]
            graph_value = np.median(measurements) - zero_min_jitter
            y_data.append(graph_value)
            low99th, high99th = (min(measurements), max(measurements))
            y_errors_min.append(graph_value - (low99th - zero_min_jitter))
            y_errors_max.append((high99th - zero_min_jitter) - graph_value)

        plt.clf()
        plt.xlabel("Requested Jitter (ns)")
        plt.ylabel("Difference in Delay (ns)")

        errorplot = plt.errorbar(jitters, y_data, yerr=(y_errors_min, y_errors_max))
        errorplot[-1][0].set_linestyle('--')
        ax = plt.gca()
        ax.set_xscale('log')
        graph_utils.set_ticks()
        plt.savefig('nrg_requested_jitter_vs_added_jitter.eps')
