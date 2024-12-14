precision = 0;

while precision < 0.95


% linha que usa o pre_processamento
[ conjunto_treino, classes_treino, conjunto_teste, classes_teste, ids_treino, ids_teste ] = pre_processamento('final.csv', 25);

% % linha que usa o segundo método de ir buscar valores (mais simples)
% [conjunto_treino, classes_treino, ids_treino, conjunto_teste, classes_teste, ids_teste] = tirar_testes('final.csv', 5);


%% Naive Bayes

[ predicoes, percentagens ] = naivebayes(conjunto_treino, classes_treino, conjunto_teste);

% Contar o número de predições corretas
num_corretas = sum(strcmp(classes_teste, predicoes'));

% Calcular a matriz de confusão para Naive Bayes
true_positive = sum(strcmp(predicoes', 'ddos') & strcmp(classes_teste, 'ddos'));
false_positive = sum(strcmp(predicoes', 'ddos') & strcmp(classes_teste, 'Benign'));
false_negative = sum(strcmp(predicoes', 'Benign') & strcmp(classes_teste, 'ddos'));
true_negative = sum(strcmp(predicoes', 'Benign') & strcmp(classes_teste, 'Benign'));

% Precision e Recall
precision = true_positive / (true_positive + false_positive);
recall = true_positive / (true_positive + false_negative);

end






figure;
confusion_matrix = [true_positive, false_positive; false_negative, true_negative];
heatmap({'Pred. ddos', 'Pred. Benign'}, {'Real ddos', 'Real Benign'}, confusion_matrix, ...
    'Title', 'Matriz de Confusão - Naive Bayes', ...
    'XLabel', 'Predições', ...
    'YLabel', 'Classes Reais');



disp('Matriz de Confusão - Naive Bayes:');
disp(['TP: ', num2str(true_positive), ', FP: ', num2str(false_positive)]);
disp(['FN: ', num2str(false_negative), ', TN: ', num2str(true_negative)]);
disp(['Precision: ', num2str(precision), ', Recall: ', num2str(recall)]);
