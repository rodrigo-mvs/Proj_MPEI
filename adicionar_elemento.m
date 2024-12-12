function BF = adicionar_elemento(elemento,BF,k,random_seeds)
% inputs : elemento (elemento a adicionar) , BF (array de bits) , k (número de hash functions)
% output : BF (atualizado)

    % repetir k vezes
    for hf = 1:k
        seed = random_seeds(hf);
        index = id_to_hash(elemento,seed);

        % garantir que o index está dentro do BF
        index = mod(index,length(BF)) + 1;

        BF(index) = 1;
    end

end