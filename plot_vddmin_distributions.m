function [] = plot_vddmin_distributions(vdd_mins, colors, labels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function plots several different VDD-min distributions for separate cache
% configurations on the same bar plot.
%
% Arguments:
%   vdd_mins -- 1xNxK matrix, where N is the number of fault map instances
%       for each cache configuration (e.g., via Monte Carlo simulation), and K is the number
%       of cache configurations.
%   colors -- Kx3 matrix, where K is the number of cache configurations
%       corresponding to those in vdd_mins. Columns are RGB fractional
%       values in the interval [0,1]. These can be generated by MATLAB
%       built-ins such as jet, hsv, flag, etc.
%   labels -- 1xK cell array, where each element is a string label
%       corresponding to the respective cache configuration.


% Check error condition
num_caches = size(vdd_mins,3);
if num_caches ~= size(colors,1) || num_caches ~= size(labels,2)
    display('ERROR: number of cache configurations must be same for vdd_mins, colors, and labels.');
    vdd_mins_size = size(vdd_mins)
    colors_size = size(colors)
    labels_size = size(labels)
    return;
end

% Build histogram
binvalues = [100:10:1000];
normcounts = NaN(size(binvalues,2), size(vdd_mins,3));
for i=1:size(vdd_mins,3)
    counts = hist(vdd_mins(:,:,i), binvalues);
    normcounts(:,i) = counts/sum(counts); % normalize counts so we can show relative frequency
end

% Plot histogram
figure = bar(binvalues, normcounts);

% Set colors and legend labels
for i=1:num_caches
    set(figure(i), 'FaceColor', colors(i,:));
    set(figure(i), 'EdgeColor', colors(i,:));
end
legend(labels);

% Axis labels
xlabel('Cache min-VDD (mV)', 'FontSize', 16, 'FontName', 'Arial');
ylabel('Relative Frequency', 'FontSize', 16, 'FontName', 'Arial');

% Axis limits
axis auto;
axis([100 1000 0 1]);

% Fonts
set(gca,'FontSize',14,'FontName','Arial');

end
