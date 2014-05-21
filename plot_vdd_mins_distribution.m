function [] = plot_vdd_mins_distribution(vdd_mins, colors, labels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function plots several different min-VDD distributions for separate cache
% configurations on the same bar plot.
%
% Arguments:
%   vdd_mins -- 1xNxC Matrix: N is the number of fault map instances
%       for each cache configuration (e.g., via Monte Carlo simulation), and C is the number
%       of cache configurations
%   colors -- Cx3 matrix, where C is the number of cache configurations
%       corresponding to those in vdd_mins. Columns are RGB fractional
%       values in the interval [0,1]. These can be generated by MATLAB
%       built-ins such as jet, hsv, flag, etc.
%   labels -- 1xC cell array, where each element is a string label
%       corresponding to the respective cache configuration.


% Check error condition
C = size(vdd_mins,3);
if C ~= size(colors,1) || C ~= size(labels,2)
    display('ERROR: number of cache configurations must be same for vdd_mins, colors, and labels.');
    vdd_mins_size = size(vdd_mins)
    colors_size = size(colors)
    labels_size = size(labels)
    return;
end

%%% CHANGE ME AS YOU LIKE %%%
% These should probably be inputs
bin_min_vdd = 100;
bin_vdd_stepsize = 10;
bin_max_vdd = 1000;

plot_min_vdd = 100;
plot_max_vdd = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Build histogram
binvalues = [bin_min_vdd : bin_vdd_stepsize : bin_max_vdd];
normcounts = NaN(size(binvalues,2), C);
for i=1:C
    counts = hist(vdd_mins(:,:,i), binvalues);
    normcounts(:,i) = counts/sum(counts); % normalize counts so we can show relative frequency
end

% Plot histogram
myfig = bar(binvalues, normcounts);

% Set colors and legend labels
for i=1:C
    set(myfig(i), 'FaceColor', colors(i,:));
    set(myfig(i), 'EdgeColor', colors(i,:));
end
legend(labels);

% Axis labels
xlabel('Cache min-VDD (mV)', 'FontSize', 16, 'FontName', 'Arial');
ylabel('Relative Frequency', 'FontSize', 16, 'FontName', 'Arial');

% Axis limits
axis auto;
axis([plot_min_vdd plot_max_vdd 0 1]);

% Fonts
set(gca,'FontSize',14,'FontName','Arial');

end