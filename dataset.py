import random
import csv
import time

def ipv4_to_number(ip):
    """Converte um endereço IPv4 para o número correspondente."""
    octets = ip.split(".")
    return sum(int(octet) * (256 ** (3 - i)) for i, octet in enumerate(octets))

def sample_filtered_balanced_csv(input_file, output_file, n_lines, selected_columns):
    """
    Realiza amostragem balanceada entre Benign e DDoS,
    filtra colunas e converte o Src IP em valor numérico.
    """
    with open(input_file, 'r') as readfile:
        header = readfile.readline().strip().split(",")
        benign_lines = []
        ddos_lines = []

        for line in readfile:
            columns = line.strip().split(",")
            
            try:
                flow_bytes = float(columns[header.index("Flow Byts/s")])
            except ValueError:
                continue

            # Ignora linhas com Flow Byts/s igual a zero
            if flow_bytes == 0:
                continue

            label = columns[-1]

            if label == "Benign":
                benign_lines.append(line)
            elif label == "ddos":
                ddos_lines.append(line)

        # Amostra balanceada
        sampled_benign = random.sample(benign_lines, n_lines // 2)
        sampled_ddos = random.sample(ddos_lines, n_lines // 2)
        balanced_sample = sampled_benign + sampled_ddos

    with open(output_file, 'w', newline='') as outfile:
        id = header[0]
        label = header[-1]
        final_columns = [id] + selected_columns + ["Num Src IP"] + [label]

        # Remove duplicatas mantendo a ordem
        final_columns = list(dict.fromkeys(final_columns))

        writer = csv.DictWriter(outfile, fieldnames=final_columns)
        writer.writeheader()

        # Processa as linhas e adiciona a coluna "Num Src IP"
        for line in balanced_sample:
            row = dict(zip(header, line.strip().split(",")))
            row["Num Src IP"] = ipv4_to_number(row["Src IP"])  # Converte Src IP

            # Filtra colunas finais
            filtered_row = {col: row[col] for col in final_columns}
            writer.writerow(filtered_row)

# Configuração inicial
start_time = time.time()

input_file = "final_dataset.csv"
output_file = "final_cleaned.csv"
n_lines = 1000
selected_columns = ["Src IP", "Src Port", "Flow Byts/s", "Flow Pkts/s", "Flow Duration", "Tot Fwd Pkts", "TotLen Fwd Pkts"]

# Executa a amostragem e processamento
sample_filtered_balanced_csv(input_file, output_file, n_lines, selected_columns)

end_time = time.time()
execution_time = end_time - start_time
print(f"Execution time: {execution_time:.2f} seconds")
print(f"Arquivo processado e salvo em '{output_file}'.")
