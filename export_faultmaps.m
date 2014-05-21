function [] = export_faultmaps(faultmaps, faultmap_IDs, output_dir, cache_ID, config_ID)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Writes a set of faultmaps to CSV files.
%
% Arguments:
%   faultmaps -- NumSets x Assoc x N Matrix: each Z-plane is a
%       single faultmap.
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
%   faultmaps/faultmap-L2-foo-1.csv
%   faultmaps/faultmap-L2-foo-2.csv
%   faultmaps/faultmap-L2-foo-3.csv
%   faultmaps/faultmap-L2-foo-4.csv
%   faultmaps/faultmap-L2-foo-5.csv

N = size(faultmaps,3);
for i=1:N
    csvwrite([output_dir '/faultmap-' cache_ID '-' config_ID '-' num2str(faultmap_IDs(i)) '.csv'], faultmaps(i));
end

end

