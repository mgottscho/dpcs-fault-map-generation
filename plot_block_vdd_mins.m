function [] = plot_block_vdd_mins(faultmaps, vdd_block_fault_cdf)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Plot the histogram of min-VDDs for all blocks in one or more faultmaps.
% The plot is "flat" in that different faultmaps are not distinguished.
%
% Arguments:
%   faultmaps -- NumSets x Assoc x N Matrix: each entry is a corresponding
%       block min-VDD.
%   vdd_block_fault_cdf -- Vx2 Matrix: rows correspond to (voltage,P_fb)
%       pairs

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

% Get the flat histogram
block_vdd_mins = faultmaps(:); % Collapse 3D faultmap matrix into a vector
[counts, binvalues] = hist(block_vdd_mins, binvalues);
normcounts = counts/sum(counts); % normalize counts so we can show relative frequency

% Compute block fault rate PMF function
vdd_block_fault_pmf = vdd_block_fault_cdf;
vdd_block_fault_pmf(2:size(vdd_block_fault_pmf,1), 2) = diff(vdd_block_fault_cdf(:, 2)); % Differentiate the CDF (not voltages)
vdd_block_fault_pmf(1, 2) = vdd_block_fault_cdf(1, 2);
vdd_block_min_vdd_pmf = vdd_block_fault_pmf; % The min-VDD is 10 mV higher than the voltage when a fault is detected
vdd_block_min_vdd_pmf(:,1) = vdd_block_min_vdd_pmf(:,1) + 10;

% Plot the min-VDD PMF function against the histogram of results
hold on;
plot(vdd_block_min_vdd_pmf(:,1), vdd_block_min_vdd_pmf(:,2));
bar(binvalues, normcounts);
hold off;

% Axis labels
xlabel('Block min-VDD (mV)', 'FontSize', 16, 'FontName', 'Arial');
ylabel('Relative Frequency', 'FontSize', 16, 'FontName', 'Arial');

% Axis limits
axis auto;
axis([plot_min_vdd plot_max_vdd 0 max(normcounts+0.02)]);

% Fonts
set(gca,'FontSize',14,'FontName','Arial');

end