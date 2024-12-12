function [BF, status] = bloom_filter(action, elemento, BF, num_hfs, random_seeds)
    % BLOOM_FILTER: Gerencia operações no Bloom Filter.
    % inputs:
    %   - action: 'add' para adicionar elemento ou 'check' para verificar elemento
    %   - elemento: o elemento a ser processado
    %   - BF: o filtro de bits atual
    %   - num_hfs: número de hash functions
    %   - random_seeds: sementes para as hash functions
    % outputs:
    %   - BF: filtro de bits atualizado (se aplicável)
    %   - status: 1 se o elemento for encontrado (em 'check'), 0 caso contrário

    if strcmp(action, 'add')
        % Adicionar elemento ao Bloom Filter
        for hf = 1:num_hfs
            seed = random_seeds(hf);
            index = mod(id_to_hash(elemento, seed), length(BF)) + 1;
            BF(index) = 1;
        end
        status = 1; % Elemento adicionado com sucesso

    elseif strcmp(action, 'check')
        % Verificar se o elemento está no Bloom Filter
        status = 1; % Assume que o elemento está presente
        for hf = 1:num_hfs
            seed = random_seeds(hf);
            index = mod(id_to_hash(elemento, seed), length(BF)) + 1;
            if BF(index) == 0
                status = 0; % Elemento não está presente
                break;
            end
        end
    else
        error('Ação inválida. Use "add" ou "check".');
    end
end
