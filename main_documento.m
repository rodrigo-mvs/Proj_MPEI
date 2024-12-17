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





docum = matriz_treino(2,:);   % documento a analisar


%% Bloom Filter
% Parâmetros do Bloom Filter

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

bf_value = verificar_elemento(id_, BF, num_hfs, random_seeds);

%% 