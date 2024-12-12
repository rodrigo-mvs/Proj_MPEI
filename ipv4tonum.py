import random
import csv
import time

def ipv4_to_number(ip):
    """Converte um endereço IPv4 para o número correspondente."""
    octets = ip.split(".")
    return sum(int(octet) * (256 ** (3 - i)) for i, octet in enumerate(octets))

def remove_rows_with_missing_values(input_file, output_file):
    """Remove linhas com valores ausentes em qualquer coluna."""
    with open(input_file, 'r') as infile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames

        with open(output_file, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()

            for row in reader:
                if all(row.values()):  # Verifica se todas as colunas têm valores não nulos
                    writer.writerow(row)

def convert_columns(input_file, output_file, ipv4_column_name, numeric_column_name):
    """Converte a coluna de IPv4 para números e garante que outra coluna seja numérica."""
    with open(input_file, 'r') as infile:
        reader = csv.DictReader(infile)
        fieldnames = [field.strip() for field in reader.fieldnames]  # Remove espaços em branco

        # Verifica se as colunas existem
        if ipv4_column_name not in fieldnames:
            raise ValueError(f"Coluna '{ipv4_column_name}' não encontrada no arquivo.")
        if numeric_column_name not in fieldnames:
            raise ValueError(f"Coluna '{numeric_column_name}' não encontrada no arquivo.")

        with open(output_file, 'w', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()

            for row in reader:
                row = {k.strip(): v for k, v in row.items()}  # Remove espaços nas chaves

                # Converter IPv4 para número
                ipv4_address = row[ipv4_column_name]
                row[ipv4_column_name] = ipv4_to_number(ipv4_address)  # Substitui o valor

                # Garantir que a coluna numérica tenha valores válidos
                try:
                    row[numeric_column_name] = float(row[numeric_column_name])
                except ValueError:
                    row[numeric_column_name] = 0.0  # Substituir valores inválidos por 0

                writer.writerow(row)

# Configuração inicial
input_file = "final.csv"
output_file_cleaned = "final_cleaned.csv"
output_file = "final.csv"
ipv4_column_name = "Src IP"
numeric_column_name = "Fwd IAT Mean"

# Remove linhas com valores ausentes
remove_rows_with_missing_values(input_file, output_file_cleaned)

# Executa a conversão nas colunas
convert_columns(output_file_cleaned, output_file, ipv4_column_name, numeric_column_name)
print(f"Arquivo processado e salvo em '{output_file}'.")