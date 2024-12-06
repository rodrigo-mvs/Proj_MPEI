function resp = verificar_elemento(elemento,BF,k)
% inputs : elemento (elemento a adicionar) , BF (array de bits) , k (número de hash functions)
% output : BF (atualizado)

resp = 1;

    % repetir k vezes
    for hf = 1:k
        index = id_to_hash(elemento);
        index = mod(index,length(BF)) + 1;
        
        if BF(indice) == 0
            resp = 0;
            break;
        end
    end

end