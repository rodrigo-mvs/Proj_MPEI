function hash = hashfunction(valor, seed)
    hash = mod((valor * seed + 31), 2^32);
end