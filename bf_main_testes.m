%% Pré-processamento

num_testes = 3000;

[header, matriz_treino, matriz_teste] = filtragem_testes('final_cleaned.csv', num_testes);

classes_treino = matriz_treino(:, end)';
conjunto_treino = cell2mat(matriz_treino(:, 3:end-1));
conjunto_teste = cell2mat(matriz_teste(:, 3:end-1));
classes_teste = matriz_teste(:, end)';
ids_treino = matriz_treino(:, 1);
ids_teste = matriz_teste(:, 1);

ids_total = [ids_teste ; ids_treino];
classes_total = [classes_teste classes_treino];

%% Bloom Filter
% Parâmetros do Bloom Filter

bf_response = zeros(1, num_testes);

num_hfs = 10;
BF_size = 144000;
random_seeds = randi([1, 1e6], 1, num_hfs);
BF = zeros(1, BF_size, "uint8");


% Adicionar apenas os IDs de 'ddos' ao Bloom Filter
for i = 1:length(ids_treino)
    if strcmp(classes_treino{i}, 'ddos') % Verifica se o ID é de ddos
        BF = adicionar_elemento(ids_treino{i},BF,num_hfs,random_seeds);
    end
end



%% Testagem

[~, ~, mat] = filtragem_testes('final_cleaned.csv', 3000);
matriz_teste2 = mat(:,1);

% Inicializar contadores
TP = 0; % Verdadeiros Positivos
FP = 0; % Falsos Positivos
TN = 0; % Verdadeiros Negativos
FN = 0; % Falsos Negativos (não deveriam existir)

% Vai armazenar os IDs Falsos Negativos do Bloom Filter
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

