x = optimvar('x',9,9,9,'Type','integer','LowerBound',0,'UpperBound',1);
%crea una variable de optimizaacion de 9x9x9 y le da un valor de 1 o 0 a
%cada x(i,j,k) => Sudoku binario

sudpuzzle = optimproblem; %objeto problema de optimizacion
mul = ones(1,1,9); 
mul = cumsum(mul,3);
sudpuzzle.Objective = sum(sum(sum(x,1),2).*mul);
%modelar el problema?

sudpuzzle.Constraints.consx = sum(x,1) == 1;
sudpuzzle.Constraints.consy = sum(x,2) == 1;
sudpuzzle.Constraints.consz = sum(x,3) == 1;
%Cada columna y fila un valor unico y cada celda 1 solo numero

majorg = optimconstr(3,3,9);

for u = 1:3
    for v = 1:3
        arr = x(3*(u-1)+1:3*(u-1)+3,3*(v-1)+1:3*(v-1)+3,:);
        majorg(u,v,:) = sum(sum(arr,1),2) == ones(1,1,9);
    end
end
sudpuzzle.Constraints.majorg = majorg;
%restricciones para subcuadrados

for u = 1:size(B,1)
    x.LowerBound(B(u,1),B(u,2),B(u,3)) = 1;
end

sudsoln = solve(sudpuzzle) %resolucion

sudsoln.x = round(sudsoln.x); %Validar Solucion

y = ones(size(sudsoln.x));
for k = 2:9
    y(:,:,k) = k; % multiplier for each depth k
end
S = sudsoln.x.*y; % multiply each entry by its depth
S = sum(S,3); % S is 9-by-9 and holds the solved puzzle
drawSudoku(S)