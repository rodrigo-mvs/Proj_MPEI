%% Pre Processamento dos Dados

% % linha que usa o pre_processamento
% [ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento('final_cleaned_v2.csv', 25);

% % linha que usa o segundo método de ir buscar valores (mais simples)
% [conjunto_treino, classes_treino, ids_treino, conjunto_teste, classes_teste, ids_teste] = tirar_testes('final_cleaned_v2.csv', 10);

[header, matriz_treino, matriz_teste] = filtragem_testes('final_cleaned_v2.csv', 200);

classes_treino = matriz_treino(:, end)';
conjunto_treino = cell2mat(matriz_treino(:, 3:end-1));
conjunto_teste = cell2mat(matriz_teste(:, 3:end-1));
classes_teste = matriz_teste(:, end)';
ids_treino = matriz_treino(:, 1)
ids_teste = matriz_teste(:, 1)


%% Naive Bayes

[ predicoes, percentagens ] = naivebayes(conjunto_treino, classes_treino, conjunto_teste);

% Contar o número de predições corretas
num_corretas = sum(strcmp(classes_teste, predicoes'));

% Calcular a matriz de confusão para Naive Bayes
true_positive = sum(strcmp(predicoes', 'ddos') & strcmp(classes_teste, 'ddos'));
false_positive = sum(strcmp(predicoes', 'ddos') & strcmp(classes_teste, 'Benign'));
false_negative = sum(strcmp(predicoes', 'Benign') & strcmp(classes_teste, 'ddos'));
true_negative = sum(strcmp(predicoes', 'Benign') & strcmp(classes_teste, 'Benign'));

figure;
confusion_matrix = [true_positive, false_positive; false_negative, true_negative];
heatmap({'Pred. ddos', 'Pred. Benign'}, {'Real ddos', 'Real Benign'}, confusion_matrix, ...
    'Title', 'Matriz de Confusão - Naive Bayes', ...
    'XLabel', 'Predições', ...
    'YLabel', 'Classes Reais');

% Precision e Recall
precision = true_positive / (true_positive + false_positive);
recall = true_positive / (true_positive + false_negative);

disp('Matriz de Confusão - Naive Bayes:');
disp(['TP: ', num2str(true_positive), ', FP: ', num2str(false_positive)]);
disp(['FN: ', num2str(false_negative), ', TN: ', num2str(true_negative)]);
disp(['Precision: ', num2str(precision), ', Recall: ', num2str(recall)]);


%% Bloom Filter
% Parâmetros do Bloom Filter
num_hfs = 5;
BF_size = 3500;
random_seeds = randi([1, 1000], 1, num_hfs);
BF = zeros(1, BF_size, "uint8");

% Inicializar contadores
bf_true_positive = 0;
bf_false_positive = 0;
bf_false_negative = 0;
bf_true_negative = 0;

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
    
    % Atualizar contadores
    if status == 1 && strcmp(classes_teste{i}, 'ddos')
        bf_true_positive = bf_true_positive + 1;
    elseif status == 1 && ~strcmp(classes_teste{i}, 'ddos')
        bf_false_positive = bf_false_positive + 1;
    elseif status == 0 && strcmp(classes_teste{i}, 'ddos')
        bf_false_negative = bf_false_negative + 1;
    elseif status == 0 && ~strcmp(classes_teste{i}, 'ddos')
        bf_true_negative = bf_true_negative + 1;
    end
end

% Valores agregados para o gráfico
bloom_results = [bf_true_positive, bf_false_positive, bf_false_negative, bf_true_negative];

% Gráfico de Falsos Positivos e Negativos (Bloom Filter)
figure;
bar(bloom_results);
set(gca, 'XTickLabel', {'TP', 'FP', 'FN', 'TN'});
title('Falsos Positivos e Negativos - Bloom Filter');
ylabel('Número de IDs');
xlabel('Categorias');


%% MinHash

matriz_ips_treino = get_IPs(matriz_treino);
matriz_ips_teste = get_IPs(matriz_teste);
shingle_length = 4;


matriz_ips_treino_benign = matriz_ips_treino(strcmpi(matriz_ips_treino(:,3), 'Benign'), :);
matriz_ips_treino_ddos = matriz_ips_treino(strcmpi(matriz_ips_treino(:,3), 'ddos'), :);


% shingles de todos os ips de ddos da matriz treino
shingles_ddos = [];

for i=1:height(matriz_ips_treino_ddos)
    temp_ip = char(matriz_ips_treino_ddos{i,2});
    temp_shingles = generate_shingles(temp_ip,shingle_length);
    

    shingles_ddos = [shingles_ddos; temp_shingles'];
end

shingles_ddos = unique(shingles_ddos);

clear temp_shingles; clear temp_ip; clear i;


% shingles de todos os ips de benignos da matriz treino
shingles_benign = [];

for i=1:height(matriz_ips_treino_benign)
    temp_ip = char(matriz_ips_treino_benign{i,2});
    temp_shingles = generate_shingles(temp_ip,shingle_length);

    shingles_benign = [shingles_benign; temp_shingles'];
end

shingles_benign = unique(shingles_benign);

clear temp_shingles; clear temp_ip; clear i;



% cell array com shingles para todos os documentos do conjunto de testes
% do tipo n(num_testes) x 1

shingles_teste = cell(length(matriz_ips_treino),1);

for i=1:length(matriz_ips_treino)
    shingles_teste{i} = generate_shingles(matriz_ips_treino{i,2},shingle_length);
end

clear i;


num_hash_funct = 1000;


%%%%%%% FAZER ASSINATURAS PARA AS MATRIZES DE TREINO
%%% FAZER MATRIZ DE RANDOMS
%%% FAZER HASHs PARA CADA SHINGLE
%%% MÍNIMO DE CADA HASHFUNCTION

assinaturas_teste_ddos = zeros(1,num_hash_funct);


