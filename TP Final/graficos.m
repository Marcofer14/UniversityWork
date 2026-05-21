% Datos proporcionados
levels = [0.3 0.4 0.5 0.6 0.7 0.8 0.9 0.95 0.98];
successRate = [1 1 1 1 1 1 1 1 1]; % Todos son 1, indicando éxito total
avgTime = [0.16227 0.15876 0.16707 0.1592 0.2282 0.20752 0.15822 0.15114 0.13345];

% Crear figura
figure;

% Gráfico 1: Tasa de éxito vs. Nivel de dificultad
subplot(2,1,1);
plot(levels, successRate, '-o', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Porcentaje de Celdas Vacías');
ylabel('Tasa de Éxito');
title('Tasa de Éxito del Método de Enteros Binarios');
grid on;
ylim([0.9 1.05]); % Ajuste del eje para visualizar mejor

% Gráfico 2: Tiempo promedio vs. Nivel de dificultad
subplot(2,1,2);
plot(levels, avgTime, '-s', 'LineWidth', 2, 'MarkerSize', 8, 'Color', 'r');
xlabel('Porcentaje de Celdas Vacías');
ylabel('Tiempo Promedio(s)');
title('Tiempo de Resolución del Método de Enteros Binarios');
grid on;

% Ajustar el diseño
sgtitle('Análisis de Performance del Método de Enteros Binarios');
