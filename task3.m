% Add your code for Task 3 in this file

% Comparison script for different POB values
% POB values to test (in hours, converted to minutes)
POB_hours = [10, 16, 24, 30];
POB_minutes = POB_hours * 60;

% Number of simulations per POB value
nSimulations = 20;

% Storage for results
results = struct();
results.POB_hours = POB_hours;
results.avgWaitingTime = zeros(length(POB_hours), nSimulations);
results.avgQueueLength = zeros(length(POB_hours), nSimulations);
results.profit = zeros(length(POB_hours), nSimulations);

% Run simulations
fprintf('Running simulations...\n');
for i = 1:length(POB_minutes)
    fprintf('\nTesting POB = %d hours (%d minutes)\n', POB_hours(i), POB_minutes(i));
    
    for j = 1:nSimulations
        fprintf('  Simulation %d/%d... ', j, nSimulations);
        
        % Run DES with current POB value
        [avgWait, avgQueue, prof] = DES(50000, [], [], POB_minutes(i), [], [], []);
        
        % Store results
        results.avgWaitingTime(i, j) = avgWait;
        results.avgQueueLength(i, j) = avgQueue;
        results.profit(i, j) = prof;
        
        fprintf('Done (Profit: %.2f)\n', prof);
    end
end

% Calculate summary statistics
results.mean_avgWaitingTime = mean(results.avgWaitingTime, 2);
results.std_avgWaitingTime = std(results.avgWaitingTime, 0, 2);
results.mean_avgQueueLength = mean(results.avgQueueLength, 2);
results.std_avgQueueLength = std(results.avgQueueLength, 0, 2);
results.mean_profit = mean(results.profit, 2);
results.std_profit = std(results.profit, 0, 2);

% Display summary table
fprintf('\n=== SUMMARY RESULTS ===\n\n');
fprintf('POB (hours) | Avg Waiting Time (min) | Avg Queue Length | Avg Profit\n');
fprintf('-----------------------------------------------------------------------\n');
for i = 1:length(POB_hours)
    fprintf('    %2d      | %8.2f ± %6.2f      | %6.2f ± %5.2f  | %10.2f ± %8.2f\n', ...
        POB_hours(i), ...
        results.mean_avgWaitingTime(i), results.std_avgWaitingTime(i), ...
        results.mean_avgQueueLength(i), results.std_avgQueueLength(i), ...
        results.mean_profit(i), results.std_profit(i));
end

% Find best POB value based on profit
[maxProfit, bestIdx] = max(results.mean_profit);
fprintf('\n=== BEST CONFIGURATION ===\n');
fprintf('Best POB: %d hours (%.2f profit)\n', POB_hours(bestIdx), maxProfit);

% Create comparison plots
figure('Position', [100, 100, 1200, 400]);

% Plot 1: Average Waiting Time
subplot(1, 3, 1);
errorbar(POB_hours, results.mean_avgWaitingTime, results.std_avgWaitingTime, 'o-', 'LineWidth', 2);
xlabel('POB Limit (hours)');
ylabel('Average Waiting Time (minutes)');
title('Average Waiting Time vs POB');
grid on;

% Plot 2: Average Queue Length
subplot(1, 3, 2);
errorbar(POB_hours, results.mean_avgQueueLength, results.std_avgQueueLength, 'o-', 'LineWidth', 2);
xlabel('POB Limit (hours)');
ylabel('Average Queue Length');
title('Average Queue Length vs POB');
grid on;

% Plot 3: Profit
subplot(1, 3, 3);
errorbar(POB_hours, results.mean_profit, results.std_profit, 'o-', 'LineWidth', 2);
xlabel('POB Limit (hours)');
ylabel('Profit');
title('Profit vs POB');
grid on;

% Save results to file
save('DES_POB_comparison_results.mat', 'results');
fprintf('\nResults saved to DES_POB_comparison_results.mat\n');

