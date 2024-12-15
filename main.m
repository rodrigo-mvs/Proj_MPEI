%% Pre Processamento dos Dados

% % linha que usa o pre_processamento
% [ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento('final_cleaned_v2.csv', 25);

% % linha que usa o segundo método de ir buscar valores (mais simples)
% [conjunto_treino, classes_treino, ids_treino, conjunto_teste, classes_teste, ids_teste] = tirar_testes('final_cleaned_v2.csv', 10);

[header, treino, teste] = filtragem_testes('final_cleaned_v2.csv', 4);

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

% Calcular valores únicos para Bloom Filter
bf_true_positive_total = sum(bf_true_positive);
bf_false_positive_total = sum(bf_false_positive);
bf_false_negative_total = sum(bf_false_negative);
bf_true_negative_total = sum(bf_true_negative);

% Vetor de resultados agregados para o gráfico
bloom_results = [bf_true_positive_total, bf_false_positive_total, bf_false_negative_total, bf_true_negative_total];

% Gráfico de Falsos Positivos e Negativos (Bloom Filter)
figure;
bar(bloom_results);
set(gca, 'XTickLabel', {'TP', 'FP', 'FN', 'TN'});
title('Falsos Positivos e Negativos - Bloom Filter');
ylabel('Número de IDs');
xlabel('Categorias');


%%

matriz_ips = get_IPs(teste);
shingles = cell(length(matriz_ips),1);

for i=1:length(matriz_ips)
    shingles{i} = generate_shingles(matriz_ips{i,2},6);
end