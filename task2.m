load dataTask2.mat
n = numel(RR);
data = RR;

lower_limit = prctile(data, 5);
upper_limit = prctile(data, 95);
upper_limit_histogram = prctile(data, 95);

edges = [0:0.05:2, 2:0.1:5];

% jitter for x values
x_base = 1; % base value
x_jitter = x_base + (rand(size(data)) - 0.5) * 0.1;

figure('Position', [100, 100, 1200, 900]);
subplot(3,2,1);
swarmchart(ones(size(data)), data, 10, 'filled');
ylabel('Value');
title('All Data Swarmchart');
xlim([0.8 1.2]);
ylim([lower_limit upper_limit]);

subplot(3,2,2);
histogram(data ,'BinEdges', edges, 'Normalization', 'probability');
xlabel('Value');
ylabel('Probability');
title('Histogram');
xlim([lower_limit upper_limit_histogram]);

edges = [0.2, 0.5, 1, 1.45, 1.8, 6]; % decided from looking at a swarm chart 
labels = {'0.2 to 0.5', '0.5 to 1', '1 to 1.45', '1.45 to 1.8', '1.8 to 6'};
ngroups = length(labels);
[group_idx, ~] = discretize(data, edges);
datacell = cell(1, ngroups);
for k = 1:ngroups
   datacell{k} = data(group_idx==k);
end
maxlen = max(cellfun(@numel, datacell));
datamatrix = nan(maxlen, ngroups);
for k = 1:ngroups
    vals = datacell{k};
    datamatrix(1:numel(vals),k) = vals;
end
subplot(3,2,3:6);
violinplot(datamatrix);
xticklabels(labels);
ylabel('Value');
title('Multiple Violin Plots showing distributions in different ranges');

elapsed_time = cumsum(data);

figure('Position', [100, 100, 1200, 900]);
plot(elapsed_time, data, '-o', 'MarkerSize', 4);
xlabel('Elapsed Time');
ylabel('Time from the prev heartbeat');
title('RR Interval Time Series');
grid on;
%ABOUT OUTLIERS AND POINTS OUTSIDE THE TYPICAL RANGE

% low values:

%Many readings are 0.01, which is probably just the lowest value the 
%heart monitor can show, so anything faster is recorded as 0.01 and 
%these points are not real outliers. You can also see values just above 
%this, like 0.05–0.1, which are likely true measurements, while the big 
%cluster at 0.01 is mostly how the device handles very fast beats, not 
%something strange. To know for sure if such short gaps between 
%heartbeats are normal or a sign of a heart problem or a sensor limit, 
%a doctor would need to look at the data.

% high values:

% The top 5 highest readings and the 50 points above 99 percentile don't
% form any cluster. Even though the whole dataset has a multimodal
% distribution these very high points look isolated, thus we can safely
% assume there are not a part of another distribution.


