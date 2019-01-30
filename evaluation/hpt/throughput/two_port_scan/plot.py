import sys
import matplotlib.pyplot as plt

if len(sys.argv) != 5:
    print "Usage plot.py <data file> <min rate> <step size> <max rate> <num packets sent>"

data_file = sys.argv[0]
min_rate = int(sys.argv[1])
step_size = int(sys.argv[2])
max_rate = int(sys.argv[3])
num_packets_sent = int(sys.argv[4])

x_data = range(min_rate, max_rate, step_size)
y_data = []
with open(data_file) as f:
    for line in f.readlines():
        y_data.append(int(line))

dropped_counts = []
for data in y_data:
    dropped_counts.append(num_packets_sent - data)


plt.bar(x_data, y_data, color='blue')
plt.bar(x_data, dropped_counts, color='red', bottom=y_data)
plt.savefig('dropped_packets.eps', format='eps')
plt.show()
