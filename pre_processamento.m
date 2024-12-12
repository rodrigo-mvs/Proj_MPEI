function [ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste, conjunto_ddos ] = pre_processamento(dataset_path, teste_percentagem)
    % PRE PROCESSAMENTO: Preparar os dados de treino e teste.
    % inputs: - caminho do dataset
    %         - percentagem de dados para teste
    % outputs: - conjunto de treino
    %          - classes do conjunto de treino
    %          - conjunto de teste
    %          - classes do conjunto de teste

    % Ler o dataset
    data = readcell(dataset_path);
    
    % Extrair os ids da primeira coluna unamed
    ids = data(2:end, 1);

    % Remover a primeira coluna
    data = data(:, 2:end);
    
    % Extrair as características e classes
    X = data(2:end, 1:end-1);          % dados das features

    X = cell2mat(X);                    % converter de célula para matriz numérica
    classes = data(2:end, end)';        % classes

    % Normalizar dados contínuos para [0, 1]
    min_vals = min(X);
    max_vals = max(X);
    X = (X - min_vals) ./ (max_vals - min_vals); % normalização

    % Separar os dados em treino e teste
    % permutação
    permutacao = randperm(size(X, 1));
    ids = ids(permutacao);
    X = X(permutacao, :);
    classes = classes(permutacao);

    % num linhas para treino[
    percentagem_treino = 100 - teste_percentagem;
    num_linhas_treino = round(percentagem_treino * size(X, 1) / 100);

    % conjuntos do treino e teste
    ids_treino = ids(1:num_linhas_treino);
    ids_teste = ids(num_linhas_treino+1:end);
    conjunto_treino = X(permutacao(1:num_linhas_treino), :);
    conjunto_teste = X(permutacao(num_linhas_treino+1:end), :);

    % classes correspondentes para o treino e teste
    classes_treino = classes(permutacao(1:num_linhas_treino));
    classes_teste = classes(permutacao(num_linhas_treino+1:end));

end