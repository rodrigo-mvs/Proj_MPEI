function [matriz_treino, classes_treino, ids_treino, matriz_teste, classes_teste, ids_teste] = tirar_testes(dataset_path, num_testes)
    % PRE PROCESSAMENTO: Preparar os dados de treino e teste.
    % inputs: - caminho do dataset
    %         - percentagem de dados para teste
    % outputs: - conjunto de treino
    %          - classes do conjunto de treino
    %          - conjunto de teste
    %          - classes do conjunto de teste

    % Ler o dataset
    data = readcell(dataset_path);
    
    % Extrair os ids da primeira coluna e remover da matriz de dados
    ids = data(2:end, 1);
    data = data(:, 2:end);
    
    % Extrair as características e classes
    X = data(2:end, 1:end-1);          % dados das features

    X = cell2mat(X);                    % converter de célula para matriz numérica
    classes = data(2:end, end);         % classes

    % Normalizar dados contínuos para [0, 1]
    min_vals = min(X);
    max_vals = max(X);
    X = (X - min_vals) ./ (max_vals - min_vals); % normalização

    % Separar os dados em treino e teste
    % 
    % % permutação
    % permutacao = randperm(size(X, 1));
    % ids = ids(permutacao);
    % X = X(permutacao, :);
    % classes = classes(permutacao);



    matriz_teste = [X(1:num_testes, :); X(end-num_testes+1:end, :)];
    matriz_treino = X(num_testes+1:end-num_testes, :);
    ids_teste = [ids(1:num_testes, :); ids(end-num_testes+1:end, :)];
    ids_treino = ids(num_testes+1:end-num_testes, :);
    classes_teste = [classes(1:num_testes, :); classes(end-num_testes+1:end, :)]';
    classes_treino = classes(num_testes+1:end-num_testes, :)';
end