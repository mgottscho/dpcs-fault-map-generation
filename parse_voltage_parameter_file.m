function [vdd_block_fault_cdf, vdd_power_energy] = parse_voltage_parameter_file(filename)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Parses a CSV file, extracting the blockwise fault probability
% CDF as a function of VDD.
%
% Arguments:
%   filename -- String: path to CSV file.
%       Column 1: VDD values
%       Column 2: Bit Error Rate CDF
%       Column 3: Block Error Rate CDF
%       Column 4: Static Power Per Data Block
%       Column 5: Static Power, Non-Data Blocks
%       Column 6: Total Dynamic Energy Per Access
%
% Returns:
%   vdd_block_fault_cdf -- Mx2 Matrix: column 1 is VDD values, column 2 is
%       block fault CDF values.
%   vdd_power_energy -- Mx4 Matrix: column 1 is VDD values, column 2 is
%       static power per data block, column 3 is static power for everything but data blocks,
%       and column 4 is total dynamic cache energy per
%       access

raw_file_input = csvread(filename, 1, 0); % Skip header row
vdd_block_fault_cdf = raw_file_input(:,1:2:3); % Extract just VDD and block error rates from input. These correspond to columns 1 and 3, respectively.
vdd_power_energy = raw_file_input(:,[1,4:6]);

end

