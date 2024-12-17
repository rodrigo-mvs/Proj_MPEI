function similarity = jaccard_d(set1, set2)
    % Calcula a similaridade de Jaccard entre dois conjuntos
    intersection_size = length(intersect(set1, set2));
    union_size = length(union(set1, set2));
    similarity = intersection_size / union_size;
end
