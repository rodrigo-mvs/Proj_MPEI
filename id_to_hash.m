function hash = id_to_hash(valor, seed)
    hash = mod((valor * seed + 31), 2^32);
end