% Generación y solución de un Sudoku aleatorio

% Definir las variables de optimización
x = optimvar('x',9,9,9,'Type','integer','LowerBound',0,'UpperBound',1);
sudpuzzle = optimproblem;

% Función objetivo (solo necesaria para definir el problema)
mul = cumsum(ones(1,1,9),3);
sudpuzzle.Objective = sum(sum(sum(x,1),2).*mul);

% Restricciones de celdas, filas y columnas
sudpuzzle.Constraints.consx = sum(x,1) == 1; % Cada celda contiene un número
sudpuzzle.Constraints.consy = sum(x,2) == 1; % Cada fila contiene un único número
sudpuzzle.Constraints.consz = sum(x,3) == 1; % Cada columna contiene un único número

% Restricciones de subcuadros (3x3)
majorg = optimconstr(3,3,9);
for u = 1:3
    for v = 1:3
        arr = x(3*(u-1)+1:3*(u-1)+3,3*(v-1)+1:3*(v-1)+3,:);
        majorg(u,v,:) = sum(sum(arr,1),2) == ones(1,1,9);
    end
end
sudpuzzle.Constraints.majorg = majorg;

% Generar un Sudoku inicial válido
rng('shuffle'); % Semilla aleatoria para diferentes ejecuciones
B = zeros(9,9,9); % Tablero inicial en 3 dimensiones

% Insertar números respetando las restricciones
filledCells = 0; % Contador de celdas llenas
while filledCells < 25 % Insertar al menos 25 números para garantizar solubilidad
    i = randi(9); % Fila aleatoria
    j = randi(9); % Columna aleatoria
    if sum(B(i,j,:)) == 0 % Solo insertar si la celda está vacía
        posibles = setdiff(1:9, [find(squeeze(B(:,j,:)) == 1); find(squeeze(B(i,:,:)) == 1); find(squeeze(B(3*ceil(i/3)-2:3*ceil(i/3),3*ceil(j/3)-2:3*ceil(j/3),:)) == 1)]');
        if ~isempty(posibles)
            k = posibles(randi(length(posibles))); % Seleccionar un valor válido
            B(i,j,k) = 1; % Asignar el valor en la tercera dimensión
            filledCells = filledCells + 1;
        end
    end
end

% Mostrar el Sudoku inicial
initialSudoku = sum(B .* reshape(1:9, [1, 1, 9]), 3); % Convertir a formato legible
disp('Sudoku inicial:');
disp(initialSudoku);

% Convertir el tablero inicial en restricciones
for i = 1:9
    for j = 1:9
        for k = 1:9
            if B(i,j,k) == 1
                sudpuzzle.Constraints.("cell_" + i + "_" + j + "_" + k) = x(i,j,k) == 1;
            end
        end
    end
end

% Resolver el Sudoku
sudsoln = solve(sudpuzzle);

% Redondear solución para evitar problemas numéricos
sudsoln.x = round(sudsoln.x);

% Reconstruir el Sudoku resuelto
y = ones(size(sudsoln.x));
for k = 2:9
    y(:,:,k) = k; % Multiplicador para cada profundidad
end
S = sudsoln.x.*y; % Multiplicar cada entrada por su profundidad
S = sum(S,3); % Colapsar la tercera dimensión

% Mostrar el Sudoku resuelto
disp('Sudoku resuelto:');
disp(S);

% Dibujo del Sudoku (puedes reemplazar "drawSudoku" con tu propia función)
if exist('drawSudoku', 'file')
    drawSudoku(S);
else
    imagesc(S);
    colormap('parula');
    axis square;
    title('Sudoku Resuelto');
end