function [] = export_runtime_vdds(runtime_vdds, voltage_capacities_power_energy, faultmap_IDs, output_dir, cache_ID, config_ID)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Writes a set of runtime VDDs to CSV files.
%
% Arguments:
%   runtime_vdds -- 1xLxN Matrix: each element in a Z-plane corresponds to a runtime
%       supply voltage for the respective faultmap.
%   voltage_capacities_power_energy -- Vx5xN Matrix: Rows correspond to all
%       possible operating VDD levels as seen by their occurrences in the
%       input faultmap.
%           Column 1: the vdd level
%           Column 2: the number of faulty blocks at that vdd level
%           Column 3: the fractional cache capacity at that vdd level
%           Column 4: the total cache static power at that vdd level
%           Column 5: the total cache dynamic energy per access at that vdd
%           level
%   faultmap_IDs -- 1xN Row Vector: number identifiers for each of the
%       faultmaps
%   output_dir -- String: path to the output directory for the file. This path must
%       be valid.
%   cache_ID -- String: the cache ID, e.g. 'L1'
%   config_ID -- String: the configuration ID, e.g. 'foo'
%
% For example, with the input arguments:
%   output_dir = 'faultmaps'
%   cache_ID = 'L2'
%   config_ID = 'foo'
%   (N == 5)
%
% The following files will be produced:
%   faultmaps/runtime-vdds-L2-foo-1.csv
%   faultmaps/runtime-vdds-L2-foo-2.csv
%   faultmaps/runtime-vdds-L2-foo-3.csv
%   faultmaps/runtime-vdds-L2-foo-4.csv
%   faultmaps/runtime-vdds-L2-foo-5.csv

L = size(runtime_vdds,2);
N = size(runtime_vdds,3);

runtime_gem5_data = NaN(3,L,N); % row 1: vdd, row 2: total cache static power, row 3: total cache dynamic energy per access

for i=1:N % for each faultmap
    runtime_gem5_data(1,:,i) = runtime_vdds(1,:,i); % copy runtime voltages for the faultmap
    for j=1:L % for each runtime voltage in the faultmap, copy the corresponding cache static power and dynamic energy over
        for k=1:size(voltage_capacities_power_energy,1) % for each
            if runtime_vdds(1,j,i) == voltage_capacities_power_energy(k,1,i) % if voltage matches
                runtime_gem5_data(2,j,i) = voltage_capacities_power_energy(k,4,i); % copy static power
                runtime_gem5_data(3,j,i) = voltage_capacities_power_energy(k,5,i); % copy dynamic energy
            end
        end
    end
    csvwrite([output_dir '/runtime-vdds-' cache_ID '-' config_ID '-' num2str(i) '-' num2str(faultmap_IDs(i)) '.csv'], runtime_gem5_data(:,:,i));
end

end

