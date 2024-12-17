function hash = hashfunction(valor, seed)
    % Função hash mais robusta com bitwise
    hash = bitxor(valor, seed);
    hash = bitxor(hash, bitshift(hash, 13));
    hash = bitxor(hash, bitshift(hash, -7));
    hash = mod(hash, 2^32);
end