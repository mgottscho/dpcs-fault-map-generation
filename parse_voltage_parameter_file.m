function [vdd_block_fault_cdf] = parse_voltage_parameter_file(filename)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Parses a CSV file, extracting the blockwise fault probability
% CDF as a function of VDD.
%
% Arguments:
%   filename -- String: path to CSV file.
%       Column 1: VDD values
%       Column 3: block fault CDF probabilities
%
% Returns:
%   vdd_block_fault_cdf -- Mx2 Matrix: column 1 is VDD values, column 2 is
%       block fault CDF values.

raw_file_input = csvread(filename, 1, 0); % Skip header row
vdd_block_fault_cdf = raw_file_input(:,1:2:3); % Extract just VDD and block error rates from input. These correspond to columns 1 and 3, respectively.

end

