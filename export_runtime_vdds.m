function [] = export_runtime_vdds(runtime_vdds, faultmap_IDs, output_dir, cache_ID, config_ID)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Writes a set of faultmaps to CSV files.
%
% Arguments:
%   runtime_vdds -- 1xLxN Matrix: each element in a Z-plane corresponds to a runtime
%       supply voltage for the respective faultmap.
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

N = size(runtime_vdds,3);
for i=1:N
    csvwrite([output_dir '/runtime-vdds-' cache_ID '-' config_ID '-' num2str(i) '-' num2str(faultmap_IDs(i)) '.csv'], runtime_vdds(:,:,i));
end

end

