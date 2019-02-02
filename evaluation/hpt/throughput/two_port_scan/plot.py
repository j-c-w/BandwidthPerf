import sys
import matplotlib
import numpy
# Avoid errors when running on headless servers.
matplotlib.use('Agg')
import matplotlib.pyplot as plt

if len(sys.argv) != 7:
    print "Usage plot.py <data file port> <min rate> <step size> <max rate> <num packets sent>"
    sys.exit(1)

width = 20

data_file = sys.argv[1]
min_rate = int(sys.argv[3])
step_size = int(sys.argv[4])
max_rate = int(sys.argv[5])
num_packets_sent = int(sys.argv[6])

x_data = numpy.arange(min_rate, max_rate + step_size, step_size)
y_data = []
error = []
with open(data_file, 'r') as f:
    for data in f.readlines():
        if len(data.split(' ')) == 1:
            y_data.append(int(data))
            error_0 = None
        else:
            values = []
            for value in data.split(' '):
                values.append(int(value))
            y_data.append(numpy.mean(values))
            error.append(numpy.std(values))

dropped_counts = []
dropped_counts = []
for data in y_data:
    dropped_counts.append(num_packets_sent - data)

plt.title('Number of drops with both ports active')
plt.xlabel('Rate into each port (Mbps)')
plt.ylabel('Packets')
plt.bar(x_data, y_data, width, color='blue', label="Port 0 Captured", y_err=error)
plt.bar(x_data, dropped_counts, width, color='red', bottom=y_data, label="Port 0 Dropped")
plt.legend()
plt.savefig('dropped_packets.eps', format='eps')
