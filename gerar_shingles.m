function shingles = gerar_shingles(text, shingle_size)
    shingles = strings(1,length(text) - shingle_size + 1);
    for i = 1:length(shingles)
        shingles(i) = text(i:i + shingle_size - 1);
    end
    shingles = unique(shingles);
end


