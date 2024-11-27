import random

def sample_large_csv(input_file, output_file, n_lines):
    
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

    # Write the sampled lines to the output file
    with open(output_file, 'w') as outfile:
        outfile.write(header)  # Write the header
        outfile.writelines(sampled_lines)






def filter_columns(input_file, output_file, selected_columns):
    """
    Filters specific columns from a sampled CSV file, including the first and last columns.
    
    Args:
    - input_file (str): Path to the sampled CSV file.
    - output_file (str): Path to save the filtered CSV file.
    - selected_columns (list): List of additional column names to include in the output.
    """
    with open(input_file, 'r') as infile:
        reader = csv.DictReader(infile)
        all_columns = reader.fieldnames  # Get all column names

        # Automatically add the first and last columns to the selection
        first_column = all_columns[0]
        last_column = all_columns[-1]
        final_columns = [first_column] + selected_columns + [last_column]

        # Ensure no duplicate columns
        final_columns = list(dict.fromkeys(final_columns))

        # Validate selected columns exist in the file
        missing_columns = [col for col in final_columns if col not in all_columns]
        if missing_columns:
            raise ValueError(f"Selected columns not found in the CSV: {missing_columns}")
        
        # Write filtered data
        with open(output_file, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=final_columns)
            writer.writeheader()  # Write the final column headers
            for row in reader:
                filtered_row = {col: row[col] for col in final_columns}
                writer.writerow(filtered_row)

# Example usage
input_file = "sampled_file.csv"  # Sampled file generated previously
output_file = "filtered_columns.csv"  # Output file with filtered columns
selected_columns = ["Flow Byts/s", "Flow Pkts/s", "Pkt Len Mean", "Fwd IAT Mean", "SYN Flag Cnt", "Active Mean"]

filter_columns(input_file, output_file, selected_columns)


















# Example usage
input_file = "final_dataset.csv"
output_file = "sampled_file.csv"
n_lines = 10000  # Number of lines you want to sample

# sample_large_csv(input_file, output_file, n_lines)
