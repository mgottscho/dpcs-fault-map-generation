function [] = plot_block_vdd_mins(faultmaps, vdd_block_fault_cdf)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Plot the histogram of min-VDDs for all blocks in one or more faultmaps.
% The plot is "flat" in that different faultmaps are not distinguished.
%
% Arguments:
%   faultmap -- NumSets x Assoc x N Matrix: each entry is a corresponding
%       block min-VDD.

% Get the flat histogram
block_vdd_mins = faultmaps(:); % Collapse 3D faultmap matrix into a vector
[counts, binvalues] = hist(block_vdd_mins, 1000); % Use 1000 bins for histogram of block vdd mins
normcounts = counts/sum(counts); % normalize counts so we can show relative frequency

% Compute block fault rate PMF function
vdd_block_fault_pmf = vdd_block_fault_cdf;
vdd_block_fault_pmf(2:size(vdd_block_fault_pmf,1), 2) = diff(vdd_block_fault_cdf(:, 2)); % Differentiate the CDF (not voltages)
vdd_block_fault_pmf(1, 2) = vdd_block_fault_cdf(1, 2);
%vdd_block_fault_pmf(:,1) = vdd_block_fault_pmf(:,1) + 20; % FIXME:
%band-aid?

% Plot the PMF function against the histogram of results
hold on;
plot(vdd_block_fault_pmf(:,1), vdd_block_fault_pmf(:,2));
bar(binvalues, normcounts);
hold off;

% Axis labels
xlabel('Block min-VDD (mV)');
ylabel('Relative Frequency');

end