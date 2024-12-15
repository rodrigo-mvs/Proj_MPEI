function [header, treino, teste] = filtragem_testes(dataset_path, num_testes)
    % FUNÇÃO: Divide o dataset em conjunto de treino e teste balanceado.
    % INPUTS:
    %   dataset_path: Caminho para o arquivo CSV.
    %   num_testes: Número total de linhas no conjunto de teste (par).
    % OUTPUTS:
    %   header: Célula com os nomes das colunas (em caixa alta).
    %   treino: Matriz com o conjunto de treino.
    %   teste: Matriz com o conjunto de teste.

    % Verifica se o número de testes é par
    if mod(num_testes, 2) ~= 0
        error('O número de linhas no conjunto de teste deve ser par.');
    end

    % Lê o dataset (preserva strings nas células)
    data = readcell(dataset_path);

    % Extrai o cabeçalho e os dados
    header = data(1, :);       % Primeira linha é o cabeçalho original
    header{1} = 'ID';          % Atualiza explicitamente o primeiro valor do cabeçalho
    
    dados = data(2:end, :);    % O resto das linhas são os dados

    % Identifica a coluna de labels (última coluna)
    labels = dados(:, end);

    % Filtra linhas por classe
    benign_idx = strcmp(labels, 'Benign'); % Índices da classe Benign
    ddos_idx = strcmp(labels, 'ddos');     % Índices da classe DDoS

    benign_dados = dados(benign_idx, :);   % Dados da classe Benign
    ddos_dados = dados(ddos_idx, :);       % Dados da classe DDoS

    % Número de casos de cada classe no conjunto de teste
    num_testes_por_classe = num_testes / 2;

    % Verifica se há exemplos suficientes para criar o conjunto de teste
    if size(benign_dados, 1) < num_testes_por_classe || size(ddos_dados, 1) < num_testes_por_classe
        error('Número insuficiente de exemplos para criar um conjunto de teste balanceado.');
    end

    % Seleciona amostras aleatórias para o conjunto de teste
    teste_benign_idx = randperm(size(benign_dados, 1), num_testes_por_classe);
    teste_ddos_idx = randperm(size(ddos_dados, 1), num_testes_por_classe);

    teste_benign = benign_dados(teste_benign_idx, :);
    teste_ddos = ddos_dados(teste_ddos_idx, :);

    % Conjunto de teste balanceado
    teste = [teste_benign; teste_ddos];

    % Remove as linhas selecionadas do conjunto de treino
    benign_dados(teste_benign_idx, :) = [];
    ddos_dados(teste_ddos_idx, :) = [];

    % Conjunto de treino (restante)
    treino = [benign_dados; ddos_dados];
end
