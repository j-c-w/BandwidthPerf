import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as st
import sys

if len(sys.argv) != 2:
    print "Usage: <script> <results file>"
    sys.exit(1)

with open(sys.argv[1]) as f:
    lines = f.readlines()

# To allow for conversion between rates.
rates_conversion = {
    'Gbits/sec': 1000,
    'Mbits/sec': 1.0,
    'Kbits/sec': 0.001,
    'bits/sec': 0.000001
}

values = {}
for line in lines:
    # Trim the newline off the end.
    line = line[:-1]
    target_rate, measured_rate = line.split(",")
    measured_rate, unit = measured_rate.split(' ')
    adjusted_measured_rate = float(measured_rate) * rates_conversion[unit]
    float_target_rate = float(target_rate)
    if float_target_rate in values:
        values[float_target_rate].append(adjusted_measured_rate)
    else:
        values[float_target_rate] = [adjusted_measured_rate]

xvalues = []
yvalues = []
error_values = []
for key in sorted(values.keys()):
    median = np.median(values[key])
    xvalues.append(key)
    yvalues.append(median)
    # Create a distribution from the measured values.
    distribution = {}
    for value in sorted(values[key]):
        if value in distribution:
            distribution[value] += 1.0
        else:
            distribution[value] = 1.0

    rv = st.rv_discrete(values=(distribution.keys(), np.array(distribution.values())/np.array(distribution.values()).sum()))

    # scipy.stats.rv_discrete has methods for median, confidence interval, etc.
    (below, above) = rv.interval(0.9)
    error_values.append((median - below, above - median))

plt.errorbar(xvalues, yvalues, yerr=np.transpose(error_values))
plt.title("Requested bandwithd vs. Measured bandwidth (iperf)")
plt.ylim([0,  10000])
plt.xlabel("Requested Bandwidth (Mbps)")
plt.ylabel("Measured Bandwidth (Mbps)")
plt.savefig('requested_vs_real_bandwidth_nrg.eps')
