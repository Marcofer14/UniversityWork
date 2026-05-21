function testSudokuSolver()
    % Niveles de vaciado a probar
    levels = [0.3, 0.4,0.5,0.6, 0.7,0.8, 0.9, 0.95, 0.98]; % 30%, 50%, 70%, 90% vaciado
    numTests = 100; % Número de Sudokus a generar por nivel

    % Resultados
    results = struct('level', [], 'successRate', [], 'avgTime', []);

    for i = 1:length(levels)
        level = levels(i);
        successCount = 0;
        totalTime = 0;

        for j = 1:numTests
            % Generar un Sudoku con el nivel de vaciado actual
            sudoku = generateSudoku();
            sudoku = removeCells(sudoku, round(81 * level));

            % Resolver el Sudoku
            tic;
            [solved, S] = solveSudokuWithBinaryInteger(sudoku);
            elapsedTime = toc;

            % Contar éxitos y acumular tiempo
            if solved
                successCount = successCount + 1;
            end
            totalTime = totalTime + elapsedTime;
        end

        % Calcular tasa de éxito y tiempo promedio
        successRate = successCount / numTests;
        avgTime = totalTime / numTests;

        % Guardar resultados
        results(i).level = level;
        results(i).successRate = successRate;
        results(i).avgTime = avgTime;

        % Mostrar resultados
        fprintf('Nivel de vaciado: %.0f%%\n', level * 100);
        fprintf('  Tasa de éxito: %.2f%%\n', successRate * 100);
        fprintf('  Tiempo promedio: %.4f segundos\n\n', avgTime);
    end

    % Mostrar resumen final
    disp('Resumen final:');
    disp(struct2table(results));
end

function [solved, S] = solveSudokuWithBinaryInteger(sudoku)
    % Convertir el Sudoku a formato binario
    B = [];
    for row = 1:9
        for col = 1:9
            if sudoku(row, col) ~= 0
                B = [B; row, col, sudoku(row, col)];
            end
        end
    end

    % Crear la variable de optimización
    x = optimvar('x', 9, 9, 9, 'Type', 'integer', 'LowerBound', 0, 'UpperBound', 1);

    % Crear el problema de optimización
    sudpuzzle = optimproblem;
    mul = ones(1, 1, 9);
    mul = cumsum(mul, 3);
    sudpuzzle.Objective = sum(sum(sum(x, 1), 2) .* mul);

    % Restricciones
    sudpuzzle.Constraints.consx = sum(x, 1) == 1;
    sudpuzzle.Constraints.consy = sum(x, 2) == 1;
    sudpuzzle.Constraints.consz = sum(x, 3) == 1;

    % Restricciones para subcuadrados
    majorg = optimconstr(3, 3, 9);
    for u = 1:3
        for v = 1:3
            arr = x(3*(u-1)+1:3*(u-1)+3, 3*(v-1)+1:3*(v-1)+3, :);
            majorg(u, v, :) = sum(sum(arr, 1), 2) == ones(1, 1, 9);
        end
    end
    sudpuzzle.Constraints.majorg = majorg;

    % Fijar valores conocidos
    for u = 1:size(B, 1)
        x.LowerBound(B(u, 1), B(u, 2), B(u, 3)) = 1;
    end

    % Resolver el problema
    try
        sudsoln = solve(sudpuzzle);
        sudsoln.x = round(sudsoln.x);

        % Convertir la solución a formato de Sudoku
        y = ones(size(sudsoln.x));
        for k = 2:9
            y(:, :, k) = k;
        end
        S = sudsoln.x .* y;
        S = sum(S, 3);

        % Verificar si la solución es válida
        solved = isValidSudoku(S);
    catch
        % Si la solución falla
        solved = false;
        S = [];
    end
end

function valid = isValidSudoku(sudoku)
    % Verificar filas
    for row = 1:9
        if length(unique(sudoku(row, :))) ~= 9
            valid = false;
            return;
        end
    end

    % Verificar columnas
    for col = 1:9
        if length(unique(sudoku(:, col))) ~= 9
            valid = false;
            return;
        end
    end

    % Verificar subcuadrados
    for u = 1:3
        for v = 1:3
            subgrid = sudoku(3*(u-1)+1:3*(u-1)+3, 3*(v-1)+1:3*(v-1)+3);
            if length(unique(subgrid(:))) ~= 9
                valid = false;
                return;
            end
        end
    end

    valid = true;
end

function sudoku = removeCells(sudoku, numCellsToRemove)
    cells = randperm(81);
    for i = 1:numCellsToRemove
        idx = cells(i);
        row = ceil(idx / 9);
        col = mod(idx - 1, 9) + 1;
        sudoku(row, col) = 0;
    end
end