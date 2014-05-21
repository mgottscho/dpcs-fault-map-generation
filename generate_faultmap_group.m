function [faultmaps, vdd_mins, vdd_mins_nofaults] = generate_faultmap_group(vdd_block_fault_cdf, cache_size_bits, associativity, bits_per_block, N)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function generates a group of faultmaps with the same parameters
% using Monte Carlo simulation.
%
% Arguments:
%   vdd_block_fault_cdf -- Nx2 Matrix: column 1 is the VDD and column 2 is the cumulative block error rate
%   cache_size_bits -- Scalar: total cache size in bits
%   associativity -- Scalar: cache associativity (number of ways in each
%   set)
%   bits_per_block -- Scalar: number of bits in each cache block
%   N -- Scalar: number of fault maps to generate
%
% Returns:
%   faultmaps -- NumSets x Assoc x N Matrix: each Z plane
%       represents the minimum non-faulty VDD the corresponding location 
%       can operate at. Voltage levels are based on those in vdd_block_fault_cdf
%   vdd_mins -- 1xN Row Vector: these are the minimum VDDs for each faultmap,
%       such that all sets in a corresponding faultmap have at least one non-faulty block
%   vdd_mins_nofaults -- 1xN Row Vector: the minimum VDDs such that no
%       blocks are faulty in the corresponding faultmap

sets = cache_size_bits/(associativity * bits_per_block);

% Pre-allocate big data structures
faultmaps = NaN(sets, associativity, N);
vdd_mins = NaN(1, N);
vdd_mins_nofaults = NaN(1, N);

% Generate the fault maps in parallel
parfor i=1:N
    %display(['Generating fault map ' num2str(i) '...']);
    [faultmap, vdd_min, vdd_min_nofaults] = generate_faultmap(vdd_block_fault_cdf, cache_size_bits, associativity, bits_per_block);
    
    % Aggregate results
	faultmaps(:,:,i) = faultmap;
    vdd_mins(i) = vdd_min;
    vdd_mins_nofaults(i) = vdd_min_nofaults;
end
