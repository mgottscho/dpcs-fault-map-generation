function [] = plot_blockwise_vddmin(faultmap_set, block_error_rate_cdf)
% Author: Mark Gottscho
% mgottscho@ucla.edu

% Get the histogram
block_vmins = faultmap_set(:); % Collapse 3D matrix into a vector
[counts, binvalues] = hist(block_vmins, 1000); % Use 1000 bins for histogram of block vmins
normcounts = counts/sum(counts); % normalize counts so we can show relative frequency

% Compute block error rate PMF function
block_error_rate_pmf = diff(block_error_rate_cdf);
block_error_rate_pmf(:,1) = block_error_rate_cdf(1:90,1);
block_error_rate_pmf(:,1) = block_error_rate_pmf(:,1) + 10;

% Plot the PMF function against the histogram of results
figure;
hold on;
plot(block_error_rate_pmf(:,1), block_error_rate_pmf(:,2));
bar(binvalues, normcounts);

% Axis labels
xlabel('Block min-VDD (mV)');
ylabel('Relative Frequency');

end