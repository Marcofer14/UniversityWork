function sudoku_3d = generateSudoku()
    % Paso 1: Crear un tablero vacío
    board = zeros(9, 9);

    % Paso 2: Llenar el tablero completo
    [success, board] = fillBoard(board, 1, 1); % <- Cambio aquí
    
    % Verificación 1: Tablero después de intentar llenarlo
    disp('Tablero generado (completo):');
    disp(board); % << Verificación 1
    if ~success
        error('No se pudo generar un Sudoku completo.');
    end

    % Paso 3: Vaciar celdas al azar
    board = removeCells(board, 30);

    % Verificación 2: Tablero después de vaciar celdas
    disp('Tablero después de vaciar celdas:');
    disp(board); % << Verificación 2

    % Paso 4: Convertir el tablero a formato 3D
    sudoku_3d = convertTo3D(board);

    % Verificación 3: Sudoku en formato 3D
    disp('Tablero en formato 3D:');
    disp(sudoku_3d); % << Verificación 3
end

function [success, board] = fillBoard(board, row, col) % <- Cambio en la definición
    if row > 9
        success = true;
        return;
    end

    nextRow = row;
    nextCol = col + 1;
    if nextCol > 9
        nextRow = row + 1;
        nextCol = 1;
    end

    nums = randperm(9);
    for num = nums
        if isValidMove(board, row, col, num)
            board(row, col) = num;
            [sub_success, new_board] = fillBoard(board, nextRow, nextCol); % <- Recibe el tablero actualizado
            if sub_success
                board = new_board; % Actualiza el tablero con los cambios de la recursión
                success = true;
                return;
            end
            board(row, col) = 0; % Backtracking
        end
    end

    success = false;
end

function valid = isValidMove(board, row, col, num)
    % Verificar fila
    if any(board(row, :) == num)
        valid = false;
        return;
    end

    % Verificar columna
    if any(board(:, col) == num)
        valid = false;
        return;
    end

    % Verificar subcuadrícula
    startRow = floor((row - 1) / 3) * 3 + 1;
    startCol = floor((col - 1) / 3) * 3 + 1;
    if any(board(startRow:startRow + 2, startCol:startCol + 2) == num, 'all')
        valid = false;
        return;
    end

    valid = true;
end

function board = removeCells(board, numCellsToRemove)
    cells = randperm(81);
    for i = 1:numCellsToRemove
        idx = cells(i);
        row = ceil(idx / 9);
        col = mod(idx - 1, 9) + 1;
        board(row, col) = 0;
    end
end

function sudoku_3d = convertTo3D(board)
    sudoku_3d = zeros(9, 9, 9);
    for row = 1:9
        for col = 1:9
            if board(row, col) ~= 0
                sudoku_3d(row, col, board(row, col)) = 1;
            end
        end
    end
end