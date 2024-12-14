function [ predicoes, probabilidades ] = naivebayes(conjunto_treino, classes_treino, conjunto_teste)
    % NAIVE BAYES: Implementação do algoritmo Naive Bayes.
    % inputs: - conjunto_treino : matriz com as características do treino
    %         - classes_treino : vetor com as classes correspondentes ao conjunto de treino
    %         - conjunto_teste : matriz com as características das amostras do teste
    % outputs: - predicoes : vetor com as predições das classes para o conjunto de teste
    %          - probabilidades : matriz com as probabilidades das classes para o conjunto de teste

    % Identificar as classes
    nomes_classes = unique(classes_treino);    % nomes das classes
    C1 = nomes_classes{1};              % nome da primeira classe
    C2 = nomes_classes{2};              % nome da segunda classe

    %% Calcular probabilidades a priori
    num_C1 = sum(strcmp(classes_treino, C1));
    num_C2 = sum(strcmp(classes_treino, C2));
    total_docs = length(classes_treino);

    prob_C1 = num_C1 / total_docs;
    prob_C2 = num_C2 / total_docs;

    %% Calcular médias e variâncias (probabilidades condicionais)
    % Para C1
    linhas_C1 = strcmp(classes_treino, C1);    % Linhas onde a classe é C1
    TREINO_C1 = conjunto_treino(linhas_C1, :); % Dados do treino para C1
    media_C1 = mean(TREINO_C1, 1);             % Média das características para C1
    var_C1 = var(TREINO_C1, 1);                % Variância das características para C1

    % Para C2
    linhas_C2 = strcmp(classes_treino, C2);    % Linhas onde a classe é C2
    TREINO_C2 = conjunto_treino(linhas_C2, :); % Dados do treino para C2
    media_C2 = mean(TREINO_C2, 1);             % Média das características para C2
    var_C2 = var(TREINO_C2, 1);                % Variância das características para C2

    %% Classificar os dados de teste
    predicoes = cell(size(conjunto_teste, 1), 1);
    probabilidades = zeros(size(conjunto_teste, 1), 2);
    for i = 1:size(conjunto_teste, 1)
        amostra = conjunto_teste(i, :);

        % Calcular P(C1 | TESTE) usando a densidade gaussiana
        p1 = prob_C1; % Probabilidade a priori
        p1 = p1 * prod((1 ./ sqrt(2 * pi * var_C1)) .* exp(-((amostra - media_C1).^2) ./ (2 * var_C1)));

        % Calcular P(C2 | TESTE) usando a densidade gaussiana
        p2 = prob_C2; % Probabilidade a priori
        p2 = p2 * prod((1 ./ sqrt(2 * pi * var_C2)) .* exp(-((amostra - media_C2).^2) ./ (2 * var_C2)));

        % Normalizar as probabilidades
        normalizador = p1 + p2;
        p1 = p1 / normalizador;
        p2 = p2 / normalizador;

        % Salvar probabilidades
        probabilidades(i, :) = [p1, p2];

        % Decidir a classe
        if p1 > p2
            predicoes{i} = C1;
        else
            predicoes{i} = C2;
        end
    end
end
