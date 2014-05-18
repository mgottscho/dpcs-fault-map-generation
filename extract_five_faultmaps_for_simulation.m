function [faultmap_samples, vdd_min_samples, faultmap_sample_indices] = extract_five_faultmaps_for_simulation(vdd_mins, block_faultmaps, output_dir, cache_ID, config_ID);
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function extracts five faultmaps from a collection of faultmaps for
% the same cache configuration, and outputs them to be used in simulation.
%
% Faultmap 1: A faultmap with the lowest (best) min-VDD of all input faultmaps.
% Faultmap 2: A faultmap with the min-VDD at the 25th percentile (worse
%   than 25% of cache instances, since lower min-VDD is better).
% Faultmap 3: A faultmap with the median min-VDD of all input faultmaps (50th percentile).
%   This represents the average or common case.
% Faultmap 4: A faultmap with the min-VDD at the 75th percentile (worse
%   than 75% of cache instances).
% Faultmap 5: A faultmap with the min-VDD at the highest (worst) min-VDD of
%   all input faultmaps.
%
% Arguments:
%   vdd_mins -- A 1xN row vector, where each entry is an integer
%       representing the min-VDD for the corresponding cache instance (and
%       corresponding faultmap).
%   block_faultmaps -- A Set x Assoc x N 3D matrix, where each entry is the
%       min-VDD for a particular cache block at address (Set,Assoc) in cache
%       instance i in the interval [1:N].
%   output_dir -- The path to the output directory where the faultmap CSVs
%       will be written.
%   cache_ID -- A string representing the cache ID, e.g. 'L1'.
%   config_id -- A string representing the config ID, e.g. 'A'.
%
% Returns:
%   faultmap_samples -- A Set x Assoc x 5 3D matrix. This has the same
%       format as block_faultmaps, but instance (index) i in
%       faultmap_samples is not the same instance (index) j in the input
%       arguments.
%   faultmap_sample_numbers -- A 1x5 row vector. This maps the input fault
%       map indices to those in the faultmap_samples output.
%
% Side effects:
%   Writes 5 CSV files to the faultmaps/ sub-directory, of the form:
%
%   <output_dir>/faultmap-<cache_ID>-<config_ID>-<map_number>.csv
%
%   Where each entry represents a single block.
%
%   For example, with the input arguments:
%       output_dir = 'faultmaps'
%       cache_ID = 'L2'
%       config_ID = 'foo'
%
%   The following files will be produced:
%       faultmaps/faultmap-L2-foo-<faultmap_sample_numbers(1)>.csv
%       faultmaps/faultmap-L2-foo-<faultmap_sample_numbers(2)>.csv
%       faultmaps/faultmap-L2-foo-<faultmap_sample_numbers(3)>.csv
%       faultmaps/faultmap-L2-foo-<faultmap_sample_numbers(4)>.csv
%       faultmaps/faultmap-L2-foo-<faultmap_sample_numbers(5)>.csv


% Error checking
number_of_faultmaps = size(vdd_mins,2);
if number_of_faultmaps ~= size(block_faultmaps,3)
   display('Number of entries in vdd_mins and block_faultmaps do not match!');
   vdd_mins_size = size(vdd_mins)
   block_faultmaps_size = size(block_faultmaps)
   return;
end


% We need to sort the faultmap inputs by order of min-VDD results.
% Note that there will be many maps that fall into each 10mV min-VDD bin.
% We choose one sample from a bin arbitrarily (e.g., we do not pay
% attention to the number of faulty blocks in the map, nor their
% distribution, but simply its operating min-VDD).
[vdd_mins_sorted, vdd_mins_sorted_indices] = sort(vdd_mins);

faultmap_sample_indices(1) = vdd_mins_sorted_indices(1);
vdd_min_samples(1) = vdd_mins_sorted(faultmap_sample_indices(1));
faultmap_samples(:,:,1) = block_faultmaps(:,:,faultmap_sample_indices(1)); % Best (0th %ile)
for i=2:5
    faultmap_sample_indices(i) = vdd_mins_sorted_indices((i-1)*1/4*number_of_faultmaps);
    vdd_min_samples(i) = vdd_mins(faultmap_sample_indices(i));
    faultmap_samples(:,:,i) = block_faultmaps(:,:,faultmap_sample_indices(i)); % (25th, 50th, 75th, and 100th %iles)
end

mkdir(output_dir);
for i=1:5
   csvwrite([output_dir '/faultmap-' cache_ID '-' config_ID '-' num2str(faultmap_sample_indices(i)) '.csv'], faultmap_samples(:,:,i)); 
end

end