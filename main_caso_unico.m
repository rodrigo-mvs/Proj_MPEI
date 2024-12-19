num_testes = 3000; % 7000 valores para treino

[header, matriz_treino, matriz_teste] = filtragem_testes('final_cleaned.csv', num_testes);

classes_treino = matriz_treino(:, end)';
conjunto_treino = cell2mat(matriz_treino(:, 3:end-1));
ids_treino = matriz_treino(:, 1);

matriz_total = [matriz_teste ; matriz_treino];

index = randi([1, length(matriz_total)]);
caso_unico = matriz_total(index, :);
id_teste = cell2mat(caso_unico(1,1));
conjunto_teste_unico = cell2mat(caso_unico(:, 3:end-1));
ip_teste = caso_unico(2);

%% Bloom Filter

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

veredito_bloomfilter = verificar_elemento(id_teste,BF,num_hfs,random_seeds);


%% Naive Bayes

[ previsao, percentagem ] = naive_bayes(conjunto_treino, classes_treino, conjunto_teste_unico);
veredito_naivebayes = strcmp(previsao,'ddos');


%% MinHash

num_hashes = 100;
num_primo = 2^31 - 1;
random_seeds = randi([1, 1e6], 1, num_hashes);
shingle_length = 8;
matriz_ips_treino = get_IPs(matriz_treino);




matriz_ips_benign = matriz_ips_treino(strcmpi(matriz_ips_treino(:,3), 'Benign'), :);
matriz_ips_ddos = matriz_ips_treino(strcmpi(matriz_ips_treino(:,3), 'ddos'), :);


% shingles de todos os ips de ddos da matriz teste
shingles_ddos = [];
assinaturas_ddos = [];

for i=1:height(matriz_ips_ddos)
    temp_ip = char(matriz_ips_ddos{i,2});
    temp_shingles = gerar_shingles(temp_ip,shingle_length);
    temp_assinatura = gerar_assinatura(temp_shingles,random_seeds,num_primo);

    shingles_ddos = [shingles_ddos; temp_shingles'];
    assinaturas_ddos = [assinaturas_ddos; temp_assinatura];
end

clear temp_shingles; clear temp_ip; clear i; clear temp_assinatura;




% shingles de todos os ips de benignos da matriz teste
shingles_benign = [];
assinaturas_benign = [];

for i=1:height(matriz_ips_benign)
    temp_ip = char(matriz_ips_benign{i,2});
    temp_shingles = gerar_shingles(temp_ip,shingle_length);
    temp_assinatura = gerar_assinatura(temp_shingles,random_seeds,num_primo);

    shingles_benign = [shingles_benign; temp_shingles'];
    assinaturas_benign = [assinaturas_benign; temp_assinatura];
end

clear temp_shingles; clear temp_ip; clear i; clear temp_assinatura;



shingles_teste = gerar_shingles(char(ip_teste), shingle_length);
assinatura_teste = gerar_assinatura(shingles_teste, random_seeds, num_primo);



dist_B = mean(sum(assinatura_teste == assinaturas_ddos, 2) / num_hashes);
dist_D = mean(sum(assinatura_teste == assinaturas_benign, 2) / num_hashes);
veredito_minhash = (dist_B > dist_D);


%%

if veredito_bloomfilter == 1
    % Se o Bloom Filter decidir que é 'ddos'
    veredito_final = 1; % Decisão final: ddos
else
    % Combinação de Naive Bayes e MinHash (votação simples)
    if (veredito_naivebayes + veredito_minhash) > 1
        veredito_final = 1; % Decisão final: ddos
    else
        veredito_final = 0; % Decisão final: benign
    end
end

disp("veredito final: " + veredito_final)
disp("valor real: " + char(caso_unico(10)))


if veredito_final
    BF = adicionar_elemento(id_teste,BF,num_hashes,random_seeds);
end