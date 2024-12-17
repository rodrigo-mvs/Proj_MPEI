function signature = gerar_assinatura(shingles, random_seeds, num_primo)
    num_hashes = length(random_seeds);
    signature = inf(1, num_hashes);
    
    for i = 1:length(shingles)
        shingle_hash = double(shingles(i));
        
        for j = 1:num_hashes
            
            hash_value = hashfunction(shingle_hash, random_seeds(j));
            hash_value = mod(hash_value, num_primo);
            
            signature(j) = min(signature(j), hash_value);
        end
    end
end