from decimal import Decimal
import matplotlib.pyplot as plt
import argparse
import sys
# Add the process_csv libraries to the import path.
sys.path.insert(0, '/root/jcw78/process_pcap_traces/')
import process_csv

if __name__ == "__main__":
    print "Extracting latency differences..."
    parser = argparse.ArgumentParser()
    parser.add_argument('unjittered_csv')
    parser.add_argument('jittered_csv')
    parser.add_argument('output_file')
    args = parser.parse_args()

    # Now, extract the two files:
    unjittered_times = process_csv.extract_times(args.unjittered_csv)
    jittered_times = process_csv.extract_times(args.jittered_csv)

    # This algorithm assumes that packet 'i' in the jittered
    # times is the same as packet 'i' in the unjittered times.
    assert len(unjittered_times) == len(jittered_times)

    differences = []
    for i in range(0, len(jittered_times)):
        differences.append(str((jittered_times[i] - unjittered_times[i]) * Decimal(1000000000.0)))

    with open(args.output_file, 'w') as outfile:
        outfile.write(','.join(differences))
