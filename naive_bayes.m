function [ previsoes, probabilidades ] = naive_bayes(conjunto_treino, classes_treino, conjunto_teste)
    % NAIVE BAYES: Implementação do algoritmo Naive Bayes.
    % inputs: - conjunto_treino : matriz com as características do treino
    %         - classes_treino : vetor com as classes correspondentes ao conjunto de treino
    %         - conjunto_teste : matriz com as características das amostras do teste
    % outputs: - predicoes : vetor com as predições das classes para o conjunto de teste
    %          - probabilidades : matriz com as probabilidades das classes para o conjunto de teste

    % Identificar as classes
    nomes_classes = unique(classes_treino);    % nomes das classes
    B = nomes_classes{1};              % nome da primeira classe
    D = nomes_classes{2};              % nome da segunda classe

    %% Calcular probabilidades a priori
    num_B = sum(strcmp(classes_treino, B));
    num_D = sum(strcmp(classes_treino, D));
    total_docs = length(classes_treino);

    prob_B = num_B / total_docs;
    prob_D = num_D / total_docs;

    %% Calcular médias e variâncias (probabilidades condicionais)
    % Para B
    linhas_B = strcmp(classes_treino, B);    % Linhas onde a classe é B
    TREINO_B = conjunto_treino(linhas_B, :); % Dados do treino para B
    media_B = mean(TREINO_B, 1);             % Média das características para B
    var_B = var(TREINO_B, 1);                % Variância das características para B

    % Para D
    linhas_D = strcmp(classes_treino, D);    % Linhas onde a classe é D
    TREINO_D = conjunto_treino(linhas_D, :); % Dados do treino para D
    media_D = mean(TREINO_D, 1);             % Média das características para D
    var_D = var(TREINO_D, 1);                % Variância das características para D

    %% Classificar os dados de teste
    previsoes = cell(size(conjunto_teste, 1), 1);
    probabilidades = zeros(size(conjunto_teste, 1), 2);

    for i = 1:size(conjunto_teste, 1)
        amostra = conjunto_teste(i, :);

        % Calcular P(B | TESTE) usando a densidade gaussiana
        pB = prob_B; % Probabilidade a priori
        pB = pB * prod((1 ./ sqrt(2 * pi * var_B)) .* exp(-((amostra - media_B).^2) ./ (2 * var_B)));

        % Calcular P(D | TESTE) usando a densidade gaussiana
        pD = prob_D; % Probabilidade a priori
        pD = pD * prod((1 ./ sqrt(2 * pi * var_D)) .* exp(-((amostra - media_D).^2) ./ (2 * var_D)));

        % Normalizar as probabilidades
        normalizador = pB + pD;
        pB = pB / normalizador;
        pD = pD / normalizador;

        % Salvar probabilidades
        probabilidades(i, :) = [pB, pD];

        % Decidir a classe
        if pB > pD
            previsoes{i} = B;
        else
            previsoes{i} = D;
        end
    end
end