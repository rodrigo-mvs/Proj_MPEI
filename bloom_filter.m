csv = readmatrix('final.csv');
ids = csv(2:end,1);

clear csv;

random_seeds = randi([1, 1000], 1, 5);

%%
BF = zeros(1,3500,"uint8");
num_hfs = 5;

for a=1:length(ids)
    BF = adicionar_elemento(ids(a),BF,num_hfs,random_seeds);
end

val_verif = 135152;          % valor teste a verificar se existe
verificar_elemento(val_verif,BF,num_hfs,random_seeds)