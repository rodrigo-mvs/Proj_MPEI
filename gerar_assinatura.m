function assinatura = gerar_assinatura(shingles, random_seeds, num_primo)
    num_hashes = length(random_seeds);
    assinatura = inf(1, num_hashes);
    
    for i = 1:length(shingles)
        shingle_string = char(shingles(i));
        hash_base = string2hash(shingle_string);
        
        for j = 1:num_hashes
            
            hash_value = hashfunction(hash_base, random_seeds(j));
            hash_value = mod(hash_value, num_primo);
            
            assinatura(j) = min(assinatura(j), hash_value);
        end
    end
end