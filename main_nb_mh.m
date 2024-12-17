%% Pre Processamento dos Dados

% % linha que usa o pre_processamento
% [ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento('final_cleaned_v2.csv', 25);

% % linha que usa o segundo método de ir buscar valores (mais simples)
% [conjunto_treino, classes_treino, ids_treino, conjunto_teste, classes_teste, ids_teste] = tirar_testes('final_cleaned_v2.csv', 10);

num_testes = 3000;

[header, matriz_treino, matriz_teste] = filtragem_testes('final_cleaned.csv', num_testes);

classes_treino = matriz_treino(:, end)';
conjunto_treino = cell2mat(matriz_treino(:, 3:end-1));
conjunto_teste = cell2mat(matriz_teste(:, 3:end-1));
classes_teste = matriz_teste(:, end)';
ids_treino = matriz_treino(:, 1);
ids_teste = matriz_teste(:, 1);

%% Naive Bayes
nb_response = zeros(1, num_testes); % Inicializa como um vetor de zeros

[ predicoes, percentagens ] = naivebayes(conjunto_treino, classes_treino, conjunto_teste);

% Contar o número de previções corretas
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

% 
% X = percentagens;
% Y = 0;
% for i = 1:100
%    if ((percentagens(i, 2) > 0.90))
%        Y = Y +1
%        nb_response(i) = 1;
%    end
% end


%% MinHash

matriz_ips = get_IPs(matriz_teste);
shingle_length = 3;

matriz_ips_benign = matriz_ips(strcmpi(matriz_ips(:,3), 'Benign'), :);
matriz_ips_ddos = matriz_ips(strcmpi(matriz_ips(:,3), 'ddos'), :);



% shingles de todos os ips de ddos da matriz teste
shingles_ddos = [];

for i=1:height(matriz_ips_ddos)
    temp_ip = char(matriz_ips_ddos{i,2});
    temp_shingles = generate_shingles(temp_ip,shingle_length);

    shingles_ddos = [shingles_ddos; temp_shingles'];
end

clear temp_shingles; clear temp_ip; clear i;


% shingles de todos os ips de benignos da matriz teste
shingles_benign = [];

for i=1:height(matriz_ips_ddos)
    temp_ip = char(matriz_ips_ddos{i,2});
    temp_shingles = generate_shingles(temp_ip,shingle_length);

    shingles_benign = [shingles_benign; temp_shingles'];
end

clear temp_shingles; clear temp_ip; clear i;







% cell array com shingles para todos os documentos do conjunto de testes
% do tipo n(num_testes) x 1

shingles_teste = cell(length(matriz_ips),1);

for i=1:length(matriz_ips)
    shingles_teste{i} = generate_shingles(matriz_ips{i,2},6);
end

function decision = minhash_classify(shingles_teste, shingles_ddos, shingles_benign)
    % Calcula a semelhança de Jaccard entre os shingles do teste e os conjuntos
    jaccard_ddos = jaccard_similarity(shingles_teste, shingles_ddos);
    jaccard_benign = jaccard_similarity(shingles_teste, shingles_benign);

    % Decide com base na maior similaridade
    if jaccard_ddos > jaccard_benign
        decision = 1; % Decisão: ddos
    else
        decision = 0; % Decisão: benign
    end
end

function similarity = jaccard_similarity(set1, set2)
    % Calcula a similaridade de Jaccard entre dois conjuntos
    intersection_size = length(intersect(set1, set2));
    union_size = length(union(set1, set2));
    similarity = intersection_size / union_size;
end



%% Matriz para resposta final
final_response = zeros(1, length(ids_teste));

% Loop para analisar cada ID de teste
for i = 1:length(ids_teste)
    if bf_response(i) == 1
        % Se o Bloom Filter decidir que é 'ddos'
        final_response(i) = 1; % Decisão final: ddos
    else
        % Se o Bloom Filter decidir que é 'benign', usar Naive Bayes e MinHash
        naive_bayes_decision = strcmp(predicoes{i}, 'ddos'); % 1 se ddos, 0 se benign
        minhash_decision = minhash_classify(shingles_teste{i}, shingles_ddos, shingles_benign);

        % Combinação de Naive Bayes e MinHash (votação simples)
        if naive_bayes_decision + minhash_decision >= 1
            final_response(i) = 1; % Decisão final: ddos
        else
            final_response(i) = 0; % Decisão final: benign
        end
    end
end

% Contar métricas finais
final_tp = sum(final_response == 1 & strcmp(classes_teste, 'ddos'));
final_fp = sum(final_response == 1 & strcmp(classes_teste, 'Benign'));
final_fn = sum(final_response == 0 & strcmp(classes_teste, 'ddos'));
final_tn = sum(final_response == 0 & strcmp(classes_teste, 'Benign'));

% Matriz de confusão
final_confusion_matrix = [final_tp, final_fp; final_fn, final_tn];

% Precision e Recall
final_precision = final_tp / (final_tp + final_fp);
final_recall = final_tp / (final_tp + final_fn);

% Exibir resultados
disp('Matriz de Confusão - Decisão Final:');
disp(['TP: ', num2str(final_tp), ', FP: ', num2str(final_fp)]);
disp(['FN: ', num2str(final_fn), ', TN: ', num2str(final_tn)]);
disp(['Precision: ', num2str(final_precision), ', Recall: ', num2str(final_recall)]);

% Visualização
figure;
heatmap({'Pred. ddos', 'Pred. Benign'}, {'Real ddos', 'Real Benign'}, final_confusion_matrix, ...
    'Title', 'Matriz de Confusão - Decisão Final', ...
    'XLabel', 'Predições', ...
    'YLabel', 'Classes Reais');
