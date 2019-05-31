import sys
import matplotlib
import numpy as np
# Avoid errors when running on headless servers.
matplotlib.use('Agg')
import matplotlib.pyplot as plt
sys.path.insert(0, '/root/jcw78/process_pcap_traces/')
import graph_utils

if len(sys.argv) < 7:
    print "Usage plot.py <min rate> <step size> <max rate> <num packets sent> <files (...)>"
    sys.exit(1)

width = 20

min_rate = int(sys.argv[1])
step_size = int(sys.argv[2])
max_rate = int(sys.argv[3])
num_packets_sent = int(sys.argv[4])
packet_size = int(sys.argv[5])

data_files = []
for i in range(6, len(sys.argv)):
    data_files.append(sys.argv[i])

x_data = np.arange(min_rate, max_rate + step_size, step_size)
y_data = None
error = None

x_data_packet_rate = []
for rate in x_data:
    x_data_packet_rate.append((float(rate) / float(8 * packet_size)))

for data_file in data_files:
    with open(data_file, 'r') as f:
        this_file_data = []
        for data in f.readlines():
            if len(data.split(' ')) == 1:
                this_file_data.append([int(data)])
            else:
                values = []
                for value in data.split(' '):
                    values.append(float(value) / 1000000.0)
                this_file_data.append(values)

    if y_data is None:
        y_data = this_file_data
    else:
        for i in range(len(y_data)):
            y_data[i]+=(this_file_data[i])

dropped_counts = []
min_dropped_counts_errors = []
max_dropped_counts_errors = []

for i in range(len(y_data)):
    y_data[i] = np.array(y_data[i]) / 1000000.0

for data in y_data:
    lost = - (data - (num_packets_sent * 2) / 1000000.0)
    value = np.median(lost)
    dropped_counts.append(value)
    print data
    print np.median(data)
    print max(data)
    min_dropped_counts_errors.append(value - min(lost))
    max_dropped_counts_errors.append(max(lost) - value)

min_errors = []
max_errors = []
for i in range(len(y_data)):
    value = np.median(y_data[i])
    min_errors.append(value - min(y_data[i]))
    max_errors.append(max(y_data[i]) - value)
    y_data[i] = value

# plt.title('Number of drops with both ports active')
plt.xlabel('Data into each port (Mbps)')
plt.ylabel('Packets Captured/Dropped (Millions)')
print len(x_data), len(y_data)
plt.errorbar(x_data, y_data, color='blue', label="Captured", yerr=(min_errors, max_errors), capsize=3)
plt.errorbar(x_data, dropped_counts, yerr=(min_dropped_counts_errors, max_dropped_counts_errors), color='red', label="Dropped",capsize=3 )
plt.xlim([0, 10000])
graph_utils.set_ticks()
# We want to show that all packets are captured at low rates.
plt.ylim([0, (num_packets_sent * 2 * 1.05) / 1000000.0])
plt.legend()
plt.savefig('dropped_packets.eps', format='eps')

# Now, plot a version with the packet rate instead.
plt.clf()
plt.xlabel('Packet rate into each port (millions of packets per second)')
plt.ylabel('Packets Captured/Dropped (Millions)')
plt.errorbar(x_data_packet_rate, y_data, color='blue', label="Captured", yerr=(min_errors, max_errors), capsize=3)
plt.errorbar(x_data_packet_rate, dropped_counts, yerr=(min_dropped_counts_errors, max_dropped_counts_errors), color='red', label="Dropped", capsize=3)
graph_utils.set_ticks()
# We want to show that all packets are captured at low rates.
plt.ylim([0, (num_packets_sent * 2 * 1.05) / 1000000.0])
plt.legend()
plt.savefig('dropped_packets_packet_rate.eps', format='eps')
