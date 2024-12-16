% function hash = id_to_hash(valor, seed)
%     hash = mod((valor * seed + 31), 2^32);
% end


function hash = id_to_hash(valor, seed)
    % Espalhamento de bits usando uma combinação de operações bitwise
    hash = bitxor(valor, seed);            % XOR entre valor e seed
    hash = bitxor(hash, bitshift(hash, 13)); % Shift left e XOR
    hash = bitxor(hash, bitshift(hash, -7)); % Shift right e XOR
    hash = mod(hash, 2^32);                % Garante que o valor fique dentro de 32 bits
end
