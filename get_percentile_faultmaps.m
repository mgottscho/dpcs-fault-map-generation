function [selected_indices] = get_percentile_faultmaps(vdd_mins, percentiles)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function extracts the indices of several faultmaps from a collection
%   that are certain percentiles as governed by their min-VDD ranking.
%
% Arguments:
%   vdd_mins -- 1xN Row Vector: each entry is an integer
%       representing the min-VDD for a corresponding faultmap.
%   percentiles -- 1xK Row Vector: each entry is a percentile rank
%       expressed in the interval (0,1].
%
% Returns:
%   selected_indices -- 1xK Row Vector: indices of the fault maps matching
%       the input percentiles.

N = size(vdd_mins,2);
K = size(percentiles,2);

rank_indices = percentiles * N;
selected_indices = NaN(1, K);

[vdd_mins_sorted, vdd_mins_sorted_indices] = sort(vdd_mins);

for i=1:K
    selected_indices(i) = vdd_mins_sorted_indices(rank_indices(i));
end

end