import argparse
import matplotlib.pyplot as plt
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("folders", type=str, nargs='+')

    args = parser.parse_args()

    # For each folder, add the things to the 
    folders = args.folders

    folder_values = {}
    for folder in folders:
        size = 100
        this_values = []
        while os.path.exists(folder + '/' + str(size) + '_output'):
            # Get the sw_lost field:
            file = open(folder + '/' + str(size) + '_output')
            line = file.readlines()[0].replace('=', ' ')
            line.split(' ')
            this_values.append(int(line[8]) + int(line[10]))
            size += 100
        plt.plot(xrange(100, size - 100, 100), this_values, label=str(size))
        plt.savefig('cap_scan_graph.eps', format='eps')
