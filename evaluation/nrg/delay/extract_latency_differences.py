import matplotlib.pyplot as plt
import argparse
import sys
# Add the process_csv libraries to the import path.
sys.path.insert(0, '/root/jcw78/process_pcap_traces/')
import process_csv

if __name__ == "__main__":
    print "Extracting latency differences..."
    parser = argparse.ArgumentParser()
    parser.add_argument('undelayed_csv')
    parser.add_argument('delayed_csv')
    parser.add_argument('output_file')
    args = parser.parse_args()

    # Now, extract the two files:
    undelayed_times = process_csv.extract_times(args.undelayed_csv)
    delayed_times = process_csv.extract_times(args.delayed_csv)

    # This algorithm assumes that packet 'i' in the delayed
    # times is the same as packet 'i' in the undelayed times.
    assert len(undelayed_times) == len(delayed_times)

    differences = []
    for i in range(0, len(delayed_times)):
        differences.append(str(delayed_times[i] - undelayed_times[i]))

    with open(args.output_file, 'w') as outfile:
        outfile.write(','.join(differences))
