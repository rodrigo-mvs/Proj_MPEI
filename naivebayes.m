%% carregar o dataset
data = readcell("nb_final.csv");
data(:, 1) = []; % Remove a primeira coluna unamed

%% extrair as características e classes
caracteristicas = data(1, 2:end-1);
X = data(2:end, 2:end-1);           % dados das features
X = cell2mat(X);                    % converter de célula para matriz numérica
classes = data(2:end, end)';        % classes

nomes_classes = unique(classes);    % nomes das classes
C1 = nomes_classes{1};              % nome da primeira classe
C2 = nomes_classes{2};              % nome da segunda classe

%% padronizar as características
mu = mean(X, 1);                    % Média de cada característica
sigma = std(X, 1);                  % Desvio padrão de cada característica
X_standardized = (X - mu) ./ sigma; % Aplicar padronização

%% separar os dados em treino e teste
% 70% dos dados para treino e 30% para teste

% permutação
permutacao = randperm(size(X_standardized, 1));

% definir percentagem para treino
percentagem = 70;
num_linhas_treino = round(percentagem * size(X_standardized, 1) / 100);

% conjuntos do treino e teste
TREINO = X_standardized(permutacao(1:num_linhas_treino), :);
TESTE = X_standardized(permutacao(num_linhas_treino+1:end), :);

% classes correspondentes para o treino e teste
classes_treino = classes(permutacao(1:num_linhas_treino));
classes_teste = classes(permutacao(num_linhas_treino+1:end));

%% calcular probabilidades das classes
prob_C1 = sum(strcmp(classes_treino, C1)) / length(classes_treino);
prob_C2 = sum(strcmp(classes_treino, C2)) / length(classes_treino);

disp(['Probabilidade de ', C1, ': ', num2str(prob_C1)]);
disp(['Probabilidade de ', C2, ': ', num2str(prob_C2)]);



%% probabilidade condicional dado C1
linhas_C1 = strcmp(classes_treino, C1); % Linhas onde a classe é C1
TREINO_C1 = TREINO(linhas_C1, :);       % Dados do treino para C1
contagem_C1 = sum(TREINO_C1, 1);        % Soma das características para C1
total_C1 = size(TREINO_C1, 1);          % Total de instâncias para C1
prob_caracteristica_dado_C1 = contagem_C1 / total_C1;

%% probabilidade condicional dado C2
linhas_C2 = strcmp(classes_treino, C2); % Linhas onde a classe é C2
TREINO_C2 = TREINO(linhas_C2, :);       % Dados do treino para C2
contagem_C2 = sum(TREINO_C2, 1);        % Soma das características para C2
total_C2 = size(TREINO_C2, 1);          % Total de instâncias para C2
prob_caracteristica_dado_C2 = contagem_C2 / total_C2;

%% classificar os dados de teste
predicoes = cell(size(classes_teste)); % inicializar vetor de predições
for i = 1:size(TESTE, 1)
    amostra = TESTE(i, :);
    
    % Calcular P(C1 | TESTE)
    p1 = prob_C1;
    for j = 1:length(amostra)
        if amostra(j) ~= 0
            p1 = p1 * prob_caracteristica_dado_C1(j);
        end
    end
    
    % Calcular P(C2 | TESTE)
    p2 = prob_C2;
    for j = 1:length(amostra)
        if amostra(j) ~= 0
            p2 = p2 * prob_caracteristica_dado_C2(j);
        end
    end
    
    % Decidir a classe
    if p1 > p2
        predicoes{i} = C1;
    else
        predicoes{i} = C2;
    end
end

% Avaliar o desempenho
accuracy = sum(strcmp(predicoes, classes_teste)) / length(classes_teste);
disp(['Precisão do modelo: ', num2str(accuracy)]);

