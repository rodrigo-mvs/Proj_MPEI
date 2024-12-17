%% Pre Processamento dos Dados

% % linha que usa o pre_processamento
% [ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento('final_cleaned_v2.csv', 25);

% % linha que usa o segundo método de ir buscar valores (mais simples)
% [conjunto_treino, classes_treino, ids_treino, conjunto_teste, classes_teste, ids_teste] = tirar_testes('final_cleaned_v2.csv', 10);

[header, matriz_treino, matriz_teste] = filtragem_testes('final_cleaned.csv', 3000);


classes_treino = matriz_treino(:, end)';
conjunto_treino = cell2mat(matriz_treino(:, 3:end-1));
conjunto_teste = cell2mat(matriz_teste(:, 3:end-1));
classes_teste = matriz_teste(:, end)';
ids_treino = matriz_treino(:, 1);
ids_teste = matriz_teste(:, 1); 

ids_total = [ids_teste ; ids_treino];
classes_total = [classes_teste classes_treino];

bf_response = zeros(1, 3000);

%% Bloom Filter
% Parâmetros do Bloom Filter
num_hfs = 10;
BF_size = 144000;
random_seeds = randi([1, 1e6], 1, num_hfs);
BF = zeros(1, BF_size, "uint8");



% % Adicionar apenas os IDs de 'ddos' ao Bloom Filter
% for i = 1:length(ids_treino)
%     if strcmp(classes_treino{i}, 'ddos') % Verifica se o ID é de ddos
%         BF = adicionar_elemento(ids_treino{i},BF,num_hfs,random_seeds);
%     end
% end
% 
% % Inicializar contadores
% TP = 0; % Verdadeiros Positivos
% FP = 0; % Falsos Positivos
% TN = 0; % Verdadeiros Negativos
% FN = 0; % Falsos Negativos (não deveriam existir)
% 
% 
% status_list = zeros(length(ids_treino), 1); % Inicializa uma lista de status
% for i = 1:length(ids_treino)
%     status = verificar_elemento(ids_treino{i}, BF, num_hfs, random_seeds);
%     status_list(i) = status; % Armazena o status de cada verificação
% 
% 
%     % Se o bloom filter classificar como ddos, colocar na lista de respostas
%     if status == 1
%         bf_response(i) = 1;
%     end
% 
%     if status == 1 && strcmp(classes_treino{i}, 'ddos')
%         TP = TP + 1; % Verdadeiro Positivo
%     elseif status == 1 && ~strcmp(classes_treino{i}, 'ddos')
%         FP = FP + 1; % Falso Positivo
%     elseif status == 0 && strcmp(classes_treino{i}, 'ddos')
%         FN = FN + 1; % Falso Negativo (indica problema!)
%     elseif status == 0 && ~strcmp(classes_treino{i}, 'ddos')
%         TN = TN + 1; % Verdadeiro Negativo
%     end
% end


status = 0;

% Adicionar apenas os IDs de 'ddos' ao Bloom Filter
for i = 1:length(ids_treino)
    if strcmp(classes_treino{i}, 'ddos') % Verifica se o ID é de ddos
        BF = adicionar_elemento(ids_treino{i},BF,num_hfs,random_seeds);
    end
end




%% Testagem

[~, ~, matriz_teste2] = filtragem_testes('final_cleaned.csv', 1000);



% Inicializar contadores
TP = 0; % Verdadeiros Positivos
FP = 0; % Falsos Positivos
TN = 0; % Verdadeiros Negativos
FN = 0; % Falsos Negativos (não deveriam existir)


ERROS = [];

status_list = zeros(length(matriz_teste2), 1); % Inicializa uma lista de status
for i = 1:length(matriz_teste2)
    status = verificar_elemento(matriz_teste2{i}, BF, num_hfs, random_seeds);
    status_list(i) = status; % Armazena o status de cada verificação


    % Se o bloom filter classificar como ddos, colocar na lista de respostas
    if status == 1
        bf_response(i) = 1;
    end

    if status == 1 && strcmp(classes_total{i}, 'ddos')
        TP = TP + 1; % Verdadeiro Positivo
    elseif status == 1 && ~strcmp(classes_total{i}, 'ddos')
        FP = FP + 1; % Falso Positivo
    elseif status == 0 && strcmp(classes_total{i}, 'ddos')
        FN = FN + 1; % Falso Negativo (indica problema!)
        ERROS = [ERROS ids_total{i}];
    elseif status == 0 && ~strcmp(classes_total{i}, 'ddos')
        TN = TN + 1; % Verdadeiro Negativo
    end
end

%% resultados


% Exibir resultados
fprintf('TP (Verdadeiros Positivos): %d\n', TP);
fprintf('FP (Falsos Positivos): %d\n', FP);
fprintf('TN (Verdadeiros Negativos): %d\n', TN);
fprintf('FN (Falsos Negativos): %d\n', FN);



% Valores agregados para o gráfico
bloom_results = [TP, FP, FN, TN];

% Gráfico de Falsos Positivos e Negativos (Bloom Filter)
figure;
bar(bloom_results);
set(gca, 'XTickLabel', {'TP', 'FP', 'FN', 'TN'});
title('Falsos Positivos e Negativos - Bloom Filter');
ylabel('Número de IDs');
xlabel('Categorias');


%% %% f
% a = 0;
% 
% for i=1:length(ids_teste)
%     for j=1:length(ids_treino)
%         if ids_teste{i} == ids_treino{j}
%             a = a + 1;
%             % ids_teste{i}
%             % ids_treino{j}
%         end
%     end
% end