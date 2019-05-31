import argparse
import matplotlib
import scipy.stats
matplotlib.use("Agg")
import sys
import matplotlib.pyplot as plt
import numpy as np
import os
sys.path.insert(0, '/root/jcw78/process_pcap_traces/')
import graph_utils

graph_utils.latexify(space_below_graph=0.4)

def tensorflow(folder, name_map):
    # In tensorflow, the performance data is in all the slaves.
    # It is identical in every one, so just take an arb one.
    machine = name_map['slave'][0]

    data_file = folder + os.path.sep + machine + os.path.sep + \
        'data' + os.path.sep + 'tensorflow-mnist'

    with open(data_file, 'r') as f:
        for line in f.readlines():
            if line.startswith("Training elapsed time"):
                # The benchmark runs for 20000 steps, so get the
                # time per step.
                performance = 20000.0 / float(line.split(' ')[3])
                return [performance]
    print "Error: no performance numbers found!"


def apache(folder, name_map):
    # All the slaves have performance numbers here.
    performance_numbers = []
    for machine in name_map['client']:
        data_file = folder + os.path.sep + machine + os.path.sep + \
            'data' + os.path.sep + 'apache_ab_out'

        with open(data_file, 'r') as f:
            for line in f.readlines():
                if line.startswith('Requests per second:'):
                    rate = float([x for x in line.split(' ') if x][3])
                    performance_numbers.append(rate)
    return performance_numbers


def memcached(folder, name_map):
    # All the slaves have different performance numbers here.
    performance = []
    for machine in name_map['client']:
        data_file = folder + os.path.sep + machine + os.path.sep + \
                'data' + os.path.sep + 'memcached_mutilate_stdout'
        with open(data_file, 'r') as f:
            for line in f.readlines():
                if line.startswith('Total QPS'):
                    rate = float(line.split(' ')[3])
                    performance.append(rate)

    return performance


def dns(folder, name_map):
    # All the slaes have different performance numbers here.
    performance = []
    for slave in name_map['client']:
        data_file = folder + os.path.sep + slave + os.path.sep + \
                'data' + os.path.sep + 'dns-out'

        with open(data_file, 'r') as f:
            for line in f.readlines():
                if 'Queries per second:' in line:
                    rate = float([x for x in line.split(' ') if x][3])
                    performance.append(rate)
    return performance


def get_performance(benchmark_name, benchmark_folder):
    # First, from the machine roles file get the server and
    # the client folders.

    role_to_name_map = {}
    with open(benchmark_folder + os.path.sep + 'MachineRoles', 'r') as f:
        lines = f.readlines()

        for line in lines:
            if benchmark_name + '-' in line:
                _, role = line.strip().split('-')
                management_ip = line.split(' ')[0].strip()

                # Now get the jname of the machien for that
                # IP.
                for line in lines:
                    if management_ip in line:
                        name = line.split(' ')[3].strip()
                        break

                if role in role_to_name_map:
                    role_to_name_map[role].append(name)
                else:
                    role_to_name_map[role] = [name]

    # How the performance is handled depends on the
    # benchmark.
    if benchmark_name == 'tensorflow':
        return tensorflow(benchmark_folder, role_to_name_map)
    elif benchmark_name == 'dns':
        return dns(benchmark_folder, role_to_name_map)
    elif benchmark_name == 'memcached':
        return memcached(benchmark_folder, role_to_name_map)
    elif benchmark_name == 'apache':
        return apache(benchmark_folder, role_to_name_map)
    else:
        print "I don't know how to extract performance numbers from",
        print benchmark_name


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('results_folders', nargs='+')
    parser.add_argument('--num-machines', default='7', dest='num_machines')

    args = parser.parse_args()

    # First, get all the individual runs out of a folder.
    benchmark_folders = []
    for folder in args.results_folders:
        folders = [folder + os.path.sep + x for x in os.listdir(folder)]
        benchmark_folders += folders

    # Now, get the benchmarks that we ran.
    # Also get the rates.
    benchmarks = []
    rates = {}
    folders_by_benchmark_rate = {}

    for folder in benchmark_folders:
        name, rate, _ = os.path.basename(folder).split('_')
        rate = int(rate)

        if name not in benchmarks:
            benchmarks.append(name)

        if name in rates:
            rates[name].append(rate)
        else:
            rates[name] = [rate]

        folders_by_benchmark_rate[name + str(rate)] = folder


    plt.clf()
    # Construct a line for every benchmark.
    for benchmark in benchmarks:
        errors_below = []
        errors_above = []
        app_performances = []
        values = []
        plotted_rates = []

        for rate in sorted(rates[benchmark]):
            folder_name = folders_by_benchmark_rate[benchmark + str(rate)]
            # Get all the benchmark runs:
            run_parent_folder = folder_name + os.path.sep + args.num_machines + '_machines' + os.path.sep + 'run'
            run_folders = os.listdir(run_parent_folder)

            # How each run is parsed depends on the type
            # of benchmark.  Parse that.
            performance = []
            for run_folder in run_folders:
                if not os.path.exists(run_parent_folder + os.path.sep + run_folder + os.path.sep + 'FAILED_WITH_TIMEOUT'):
                    performance+=get_performance(benchmark, run_parent_folder + os.path.sep + run_folder)

            print benchmark
            print len(performance)
            if len(performance) > 0:
                app_performances.append(performance)
                plotted_rates.append(rate)
            else:
                print "No performance numbers found for ", run_parent_folder
        # We normalize with respect to the highest available
        # bandwidth.
        highest_median = None
        for performance in app_performances:
            if highest_median:
                highest_median = \
                    max(np.median(performance), highest_median)
            else:
                highest_median = np.median(performance)

        for i in range(len(app_performances)):
            app_performances[i] = np.array(app_performances[i]) / highest_median

        for performance in app_performances:
            value = np.median(performance)
            values.append(value)
            low_percentile, high_percentile = np.percentile(performance, [25, 75])
            errors_below.append(value - low_percentile)
            errors_above.append(high_percentile - value)

        print benchmark
        print plotted_rates
        plt.errorbar(plotted_rates, values, yerr=(errors_below, errors_above), label=benchmark, capsize=5)
    plt.ylabel('Normalized Performance')
    plt.xlabel('Bandwidth Limit (Mbps)')
    graph_utils.set_legend_below(ncol=4)
    graph_utils.set_ticks()
    graph_utils.set_non_negative_axes()
    plt.xlim([0, 10000])
    filename = 'bandwidth_vs_performance.eps'
    plt.savefig(filename)
    print "Done! File saved in: ", filename
