import sys
import matplotlib
import numpy
# Avoid errors when running on headless servers.
matplotlib.use('Agg')
import matplotlib.pyplot as plt

if len(sys.argv) != 7:
    print "Usage plot.py <data file port 1> <data file port 2> <min rate> <step size> <max rate> <num packets sent>"
    sys.exit(1)

width = 20

data_file1 = sys.argv[1]
data_file2 = sys.argv[2]
min_rate = int(sys.argv[3])
step_size = int(sys.argv[4])
max_rate = int(sys.argv[5])
num_packets_sent = int(sys.argv[6])

x_data = numpy.arange(min_rate, max_rate + step_size, step_size)
y_data_0 = []
y_data_1 = []
error_0 = []
error_1 = []
print data_file2
with open(data_file1, 'r') as f:
    for data in f.readlines():
        if len(data.split(' ')) == 1:
            y_data_0.append(int(data))
            error_0 = None
        else:
            values = []
            for value in data.split(' '):
                values.append(int(value))
            y_data_0.append(np.mean(values))
            error_0.append(np.std(values))

with open(data_file2, 'r') as g:
    for data in g.readlines():
        if len(data.split(' ')) == 1:
            y_data_1.append(int(data))
            error_1 = None
        else:
            values = []
            for value in data.split(' '):
                values.append(int(value))
            y_data_1.append(np.mean(values))
            error_1.append(np.std(values))

dropped_counts_0 = []
dropped_counts_1 = []
for data in y_data_0:
    dropped_counts_0.append(num_packets_sent - data)

for data in y_data_1:
    dropped_counts_1.append(num_packets_sent - data)


plt.title('Number of drops with both ports active')
plt.xlabel('Rate into each port (Mbps)')
plt.ylabel('Packets')
plt.bar(x_data, y_data_0, width, color='blue', label="Port 0 Captured", y_err=error_0)
plt.bar(x_data, dropped_counts_0, width, color='red', bottom=y_data_0, label="Port 0 Dropped")
plt.bar(x_data + width, y_data_1, width, color='green', label="Port 1 Captured", y_err=error_1)
plt.bar(x_data + width, dropped_counts_1, width, color='orange', bottom=y_data_1, label="Port 1 Dropped")
plt.legend()
plt.savefig('dropped_packets.eps', format='eps')
