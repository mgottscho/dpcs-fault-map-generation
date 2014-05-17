function [faultmap] = generate_fault_map(vdd_block_fault_cdf, cache_size_bits, associativity, bits_per_block)
% Author: Mark Gottscho
% mgottscho@ucla.edu
% 
% This function computes the minimum non-faulty VDD for each cache block.
%
% Arguments:
%   vdd_block_fault_cdf -- Nx2 matrix where column 1 is the VDD and column 2 is the cumulative block error rate
%   cache_size_bits -- total cache size in bits
%   associativity -- cache associativity (number of ways in each set)
%   bits_per_block -- number of bits in each cache block
% 
% Returns:
%   faultmap -- a matrix, where each entry represents the minimum non-faulty
%       VDD the corresponding location can operate at. Voltage levels and
%       units match those in the input parameter file. Rows correspond to
%       cache sets while columns correspond to blocks in each set (different ways).
%
% Note that this code can be used to generate fault maps at arbitrary granularity.
% For example if interested in 64B cache block granularity for a 64KB 4-way cache:
%   cache_size_bits = 64*2^10*8 = 524288 bits
%   associativity = 4 blocks
%   bits_per_block = 64*8 = 512 bits/block
%   --> # sets is 256
%   Each output entry would be the minimum VDD for the corresponding (set,way) cache block.
%
% Alternatively for the same 64KB 4-way cache with 64B blocks you can get the fault map at bit-level as follows:
%   cache_size_bits = 64*2^10*8 = 524288 bits
%   associativity = 512*4 = 2048 blocks
%   bits_per_block = 1 bits/block
%   --> # sets is still 256
%   Each output entry would be the minimum VDD for the corresponding (set,bit) bit.
%   You could re-map this bit-level fault map to a 64B block-level faultmap using another external script if necessary,
%   but you can't regenerate a fine bit-level fault map from a block-level fault map once generated.

sets = cache_size_bits/(associativity*bits_per_block); % Compute number of cache sets

randommap = rand([sets,associativity]); % Generate uniform random variables on the interval [0,1] for each block
faultmap = ones(sets,associativity) * vdd_block_fault_cdf(1,1); % Initialize fault map to indicate min safe VDD is nominal for all blocks. Assume nominal VDD can never have faults.

% For this block, starting at first VDD below nominal, loop down the voltages until
% the random number in interval [0,1] for this block is greater than
% the block fault CDF at the current voltage. When this condition happens,
% the previous voltage was the lowest non-faulty voltage.
for vdd_index = 2:size(vdd_block_fault_cdf,1)
    faultmap(randommap > vdd_block_fault_cdf(vdd_index,2)) = vdd_block_fault_cdf(vdd_index-1,1);
end
