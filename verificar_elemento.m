function resp = verificar_elemento(elemento,BF,k,random_seeds)
% inputs : elemento (elemento a adicionar) , BF (array de bits) , k (número de hash functions)
% output : BF (atualizado)

resp = 1;

    % repetir k vezes
    for hf = 1:k
        seed = random_seeds(hf);

        index = hashfunction(elemento,seed);
        index = mod(index,length(BF)) + 1;
        
        if BF(index) == 0
            resp = 0;
            break;
        end
    end

end