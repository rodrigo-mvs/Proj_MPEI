function ips = get_IPs(dataset)
    % Função para processar um dataset completo e retornar uma nova matriz.
    % INPUT:
    %   dataset: Célula contendo as linhas do dataset original.
    % OUTPUT:
    %   nova_matriz: Matriz transformada contendo [ID, 'Src IP + Port', Label].

    % Inicializa uma matriz de saída
    ips = cell(size(dataset, 1), 3); % Três colunas: ID, Src IP + Port, Label

    % Processa cada linha do dataset
    for i = 1:size(dataset, 1)
        % Extrai os valores relevantes
        id = dataset{i, 1};                  % ID
        src_ip = dataset{i, 2};              % Src IP
        src_port = num2str(dataset{i, 3});   % Src Port convertido para string
        label = dataset{i, end};             % Label (última coluna)

        % Concatena 'Src IP + Port'
        src_ip_port = [src_ip, ':', src_port];

        % Adiciona a linha transformada à nova matriz
        ips{i, 1} = id;
        ips{i, 2} = src_ip_port;
        ips{i, 3} = label;
    end
end
