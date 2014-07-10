function [faultmap, vdd_min, vdd_min_nofaults] = generate_faultmap(vdd_block_fault_cdf, cache_size_bits, associativity, bits_per_block)
% Author: Mark Gottscho
% mgottscho@ucla.edu
% 
% This function computes the minimum non-faulty VDD for each cache block.
%
% Arguments:
%   vdd_block_fault_cdf -- Nx2 Matrix: column 1 is the VDD and column 2 is the cumulative block error rate
%   cache_size_bits -- Scalar: total cache size in bits
%   associativity -- Scalar: cache associativity (number of ways in each set)
%   bits_per_block -- Scalar: number of bits in each cache block
% 
% Returns:
%   faultmap -- NumSets x Assoc Matrix: each entry represents the minimum non-faulty
%       VDD the corresponding location can operate at. Voltage levels are based on those in vdd_block_fault_cdf
%   vdd_min -- Scalar: this is the minimum VDD such that all sets have at least one
%       non-faulty block
%   vdd_min_nofaults -- Scalar: the minimum VDD such that no blocks are
%       faulty
%
% Note that this code can be used to generate a fault map at arbitrary granularity.
% For example if interested in 64B cache block granularity for a 64KB 4-way cache:
%   cache_size_bits = 64*2^10*8 = 524288 bits
%   associativity = 4 blocks
%   bits_per_block = 64*8 = 512 bits/block
%   --> # sets is 256
%   Each faultmap entry would be the minimum VDD for the corresponding (set,way) cache block.
%
% Alternatively for the same 64KB 4-way cache with 64B blocks you can get the fault map at bit-level as follows:
%   cache_size_bits = 64*2^10*8 = 524288 bits
%   associativity = 512*4 = 2048 blocks
%   bits_per_block = 1 bits/block
%   --> # sets is still 256
%   Each faultmap entry would be the minimum VDD for the corresponding (set,bit) bit.
%   You could re-map this bit-level fault map to a 64B block-level faultmap externally,
%   but you can't regenerate a fine bit-level fault map from a block-level fault map once generated.

sets = cache_size_bits/(associativity * bits_per_block); % Compute number of cache sets
randommap = rand([sets, associativity]); % Generate uniform random variables on the interval [0,1] for each block
faultmap = ones(sets, associativity) * vdd_block_fault_cdf(1,1); % Initialize fault map to nominal VDD.
                                                                 % We assume that nominal VDD can never have any faults.

for vdd_index = 2:size(vdd_block_fault_cdf,1)
    faultmap(randommap > vdd_block_fault_cdf(vdd_index,2)) = vdd_block_fault_cdf(vdd_index,1);
end

% Compute both vdd-min cases on the generated faultmap
vdd_min_per_set = min(faultmap, [], 2); % For each set, compute what the minimum VDD is. This is due to the constraint that each set must have at least one non-faulty block.
vdd_min = max(vdd_min_per_set); % Take the maximum of setwise vdd mins for correct operation
vdd_min_nofaults = max(max(faultmap)); % min-VDD for a baseline non-faulty cache is the maximum of each block's min-VDD
    
