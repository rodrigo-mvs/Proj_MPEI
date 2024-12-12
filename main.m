%% Pre Processamento dos Dados

[ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento("final.csv", 20);

%% Naive Bayes

[ predicoes, percentagens ] = naivebayes(conjunto_treino, classes_treino, conjunto_teste);

% Contar o número de predições corretas
num_corretas = sum(strcmp(classes_teste, predicoes'));

% Calcular a precisão
precisao = num_corretas / length(classes_teste);

%% Bloom Filter
% Parâmetros do Bloom Filter
num_hfs = 5;
BF_size = 3500;
random_seeds = randi([1, 1000], 1, num_hfs);
BF = zeros(1, BF_size, "uint8");

% Adicionar apenas os IDs de 'ddos' ao Bloom Filter
for i = 1:length(ids_treino)
    if strcmp(classes_treino{i}, 'ddos') % Verifica se o ID é de ddos
        [BF, ~] = bloom_filter('add', ids_treino{i}, BF, num_hfs, random_seeds);
    end
end

% Verificar os IDs do conjunto de teste no Bloom Filter
status_list = zeros(length(ids_teste), 1); % Inicializa uma lista de status
for i = 1:length(ids_teste)
    [~, status] = bloom_filter('check', ids_teste{i}, BF, num_hfs, random_seeds);
    status_list(i) = status; % Armazena o status de cada verificação
end

% Exibir resultados
for i = 1:length(ids_teste)
    if status_list(i) == 1
        disp(['ID ', num2str(ids_teste{i}), ' pode estar no conjunto de ddos.']);
    else
        disp(['ID ', num2str(ids_teste{i}), ' não está no conjunto de ddos.']);
    end
end


