function [faultmaps, vdd_mins, vdd_mins_nonfaulty] = generate_fault_maps(ber_filename, cache_size_bits, associativity, bits_per_block, map_numbers, output_enable, output_dir, cache_ID, config_ID)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function automates the generation of several fault map files for use in the
% gem5 simulation.
%
% Arguments:
%   ber_filename -- the CSV file to read
%   cache_size_bits -- total cache size in bits
%   associativity -- cache associativity
%   bits_per_block -- number of bits in each cache block
%   map_numbers -- row vector of numbers identifying unique fault maps for use in matching
%       Monte Carlo simulation, e.g. [1:5] for 5 unique fault maps.
%   output_enable -- 1 if you want files to be generated
%   output_dir -- path to directory to save fault map files
%   cache_ID -- string representing which cache, e.g. "L2"
%   config_ID -- string representing the system configuration, e.g. "foo"
%
%
% Returns:
%   faultmaps -- a 3D matrix where each Z plane corresponds to a single faultmap
%   vdd_mins -- a row vector where each element corresponds to the minimum VDD
%       for the corresponding faultmap. This is found as the max of
%       the minimum VDD for all entries in the map, or the min voltage
%       such that all sets have at least one non-faulty entry.
%   vdd_mins_nonfaulty -- a row vector where each element corresponds to the minimum VDD
%       the cache could be operated without any faults.
% 
% Outputs:
%   If output_enable is set to 1, one CSV file will be produced for each 
%   unique fault map generated, of the form:
%
%   <output_dir>/faultmap-<cache_ID>-<config_ID>-<map_number>.csv
%
%   Where each entry represents a single block.
%
%   For example, with the input arguments:
%       output_dir = 'faultmaps'
%       cache_ID = 'L2'
%       config_ID = 'foo'
%       map_numbers = [1:5]
%
%   The following files will be produced:
%       faultmaps/faultmap-L2-foo-1.csv
%       faultmaps/faultmap-L2-foo-2.csv
%       faultmaps/faultmap-L2-foo-3.csv
%       faultmaps/faultmap-L2-foo-4.csv
%       faultmaps/faultmap-L2-foo-5.csv
%
% The fault rates specified in the input file should match those of the block size parameter.
% For example, if the bits_per_block parameter is 512, then each BER in the input file should be probabilities
% of failure for a 512-bit chunk.
%
% See the README for more details on expected file formats in the dpcs-gem5
% framework.

sets = cache_size_bits/(associativity * bits_per_block);

% Inform user
display(['Generating ' num2str(map_numbers(size(map_numbers,2))) ' fault maps...']);
display(['Cache config: ' num2str(cache_size_bits) ' bits, ' num2str(associativity) '-way, ' num2str(sets) ' sets, ' num2str(bits_per_block) ' bits/block']);

% Read the file, init
raw_file_input = csvread(ber_filename, 1, 0);
vdd_ber_cdf = raw_file_input(:,1:2); % Extract just VDD and block error rates from input

% Generate the fault maps and optionally output to files
faultmaps = NaN(sets, associativity, map_numbers(size(map_numbers,2))); % Allocate a 3D matrix. Each Z plane is one faultmap. Z indices correspond to map_number indices that were input.
vdd_mins = NaN(1, map_numbers(size(map_numbers, 2))); % Row vector of vdd_mins for each faultmap
vdd_mins_nonfaulty = NaN(1, map_numbers(size(map_numbers, 2))); % Row vector of vdd_mins_nonfaulty for each faultmap

% Parallel for loop. Each iteration is independent of the others, except for the faultmaps aggregation. This should scale to many threads if possible.
parfor map_number = map_numbers(1:size(map_numbers,2))
    display(['Generating fault map ' num2str(map_number) '...']);
    faultmap = generate_fault_map(vdd_ber_cdf, cache_size_bits, associativity, bits_per_block);
    setwise_vdd_mins = min(faultmap, [], 2); % For each set, see what the minimum VDD is. This is because each set must have at least one non-faulty block.
    vdd_mins(map_number) = max(setwise_vdd_mins); % Take the maximum of setwise vdd mins for correct operation
    vdd_mins_nonfaulty(map_number) = max(max(faultmap)); % VDD min for nonfaulty cache would be max of all blockwise min VDDs
    
	faultmaps(:,:,map_number) = faultmap; % save the faultmap into data structure
    
    if output_enable == 1 % Output faultmap to file, needed for simulation purposes
        csvwrite([output_dir '/faultmap-' cache_ID '-' config_ID '-' num2str(map_number) '.csv'], faultmap);
    end
end
