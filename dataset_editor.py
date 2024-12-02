import random
import csv

def sample_csv(input_file, output_file, n_lines):
    
    with open(input_file, 'r') as readfile:
        header = readfile.readline()  # Lê e salva o cabeçalho
        sampled_lines = []

        for i, line in enumerate(readfile, start=1):
            if i <= n_lines:
                sampled_lines.append(line)
            else:
                r = random.randint(1, i)
                if r <= n_lines:
                    sampled_lines[r - 1] = line


    with open(output_file, 'w') as outfile:
        outfile.write(header)
        outfile.writelines(sampled_lines)

def sample_csv_balanced(input_file, output_file, n_lines):

    with open(input_file, 'r') as readfile:
        header = readfile.readline().strip()
        benign_lines = []
        ddos_lines = []

        for line in readfile:
            label = line.strip().split(",")[-1]
            if label == "Benign":
                benign_lines.append(line)
            elif label == "ddos":
                ddos_lines.append(line)

        sampled_benign = random.sample(benign_lines, n_lines // 2)
        sampled_ddos = random.sample(ddos_lines, n_lines // 2)

        balanced_sample = sampled_benign + sampled_ddos
        random.shuffle(balanced_sample) 

    with open(output_file, 'w') as outfile:
        outfile.write(header + "\n")
        outfile.writelines(balanced_sample)

def filter_columns(input_file, output_file, selected_columns):
    with open(input_file, 'r') as infile:
        reader = csv.DictReader(infile)
        all_columns = reader.fieldnames

        first_column = all_columns[0]
        last_column = all_columns[-1]
        final_columns = [first_column] + selected_columns + [last_column]

        final_columns = list(dict.fromkeys(final_columns))

        with open(output_file, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=final_columns)
            writer.writeheader()  # Write the final column headers
            for row in reader:
                filtered_row = {col: row[col] for col in final_columns}
                writer.writerow(filtered_row)

def sample_filtered_balanced_csv(input_file, output_file, n_lines, selected_columns):
    with open(input_file, 'r') as readfile:
        header = readfile.readline().strip().split(",")
        benign_lines = []
        ddos_lines = []

        for line in readfile:
            label = line.strip().split(",")[-1]
            if label == "Benign":
                benign_lines.append(line)
            elif label == "ddos":
                ddos_lines.append(line)

        sampled_benign = random.sample(benign_lines, n_lines // 2)
        sampled_ddos = random.sample(ddos_lines, n_lines // 2)

        balanced_sample = sampled_benign + sampled_ddos

    with open(output_file, 'w', newline='') as outfile:
        first_column = header[0]
        last_column = header[-1]
        final_columns = [first_column] + selected_columns + [last_column]

        final_columns = list(dict.fromkeys(final_columns))

        writer = csv.DictWriter(outfile, fieldnames=final_columns)
        writer.writeheader()

        for line in balanced_sample:
            row = dict(zip(header, line.strip().split(",")))
            filtered_row = {col: row[col] for col in final_columns}
            writer.writerow(filtered_row)


input_file = "final_dataset.csv"
output_file = "final.csv"
n_lines = 10
selected_columns = ["Flow Byts/s", "Flow Pkts/s", "Pkt Len Mean", "Fwd IAT Mean", "SYN Flag Cnt", "Active Mean"]

sample_filtered_balanced_csv(input_file, output_file, n_lines, selected_columns)