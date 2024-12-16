function shingles = generate_shingles(text, shingle_size)

    num_shingles = length(text) - shingle_size + 1;
    shingles = cell(1, num_shingles);

    for i = 1:num_shingles
        shingles{i} = text(i:i + shingle_size - 1);
    end

    % Remove shingles duplicados
    shingles = unique(shingles);
end
