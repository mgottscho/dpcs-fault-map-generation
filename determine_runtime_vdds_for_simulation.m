function [runtime_vdds, yield_limited, voltage_possibilities] = determine_runtime_vdds_for_simulation(faultmap, nom_vdd, min_vdd, capacity_levels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function determines the runtime VDD levels for architectural simulation
% given a cache faultmap.
%
% Arguments:
%   faultmap -- A NumSets x Assoc 2D matrix faultmap. Each entry represents
%       the minimum supply voltage that the block can operate at without
%       any faults.
%   nom_vdd -- The nominal VDD
%   min_vdd -- A scalar indicating the absolute minimum VDD that the cache
%       must not go below. This is considered for yield reasons (e.g. set
%       yield constraint for DPCS -- see DAC'14 paper).
%   capacity_levels -- A 1xN row vector. Each entry corresponds to the
%       minimum proportion of NON-faulty blocks that must be available at that
%       voltage. For example, for VDD1 requirement of at least 50%
%       non-faulty blocks, then capacity_levels(1) = 0.5.
%       
% Returns:
%   runtime_vdds -- A 1xN row vector. Each entry corresponds to a runtime
%       supply voltage for the cache. Each entry is guaranteed to meet the
%       constraints of the capacity_levels input, plus the min-VDD input.
%       
%       runtime_vdds(N) is guaranteed to be less than or equal to
%       runtime_vdds(N-1), etc.
%       runtime_vdds(:) are guaranteed to be greater than or equal to
%       min_vdd, and less than or equal to nom_vdd.
%
%   yield_limited -- If any of the runtime VDDs are limited by the min-VDD constraint rather 
%       than the input capacity level, then the corresponding yield_limited 
%       flag will be set for that VDD level.
%   voltage_possibilities -- A Mx3 2D matrix. Rows correspond to all
%       candidate operating VDD levels as seen by their occurrences in the
%       input faultmap.
%           Column 1: the vdd level
%           Column 2: the number of faulty blocks at that vdd level
%           Column 3: the fractional cache capacity at that vdd level

num_vdds = size(capacity_levels, 2); % number of runtime vdds
num_blocks = size(faultmap,1) * size(faultmap,2); % number of blocks in the cache

% Find all possible candidate VDD levels. This is the set of blockwise
% min-VDDs found in the faultmap input.
all_possible_vdds = flipud(unique(faultmap)); % first index is highest VDD

% Error condition
if max(all_possible_vdds) > nom_vdd
    display('Found a blockwise min-VDD that exceeds the nominal VDD! :(');
    return;
end
num_possible_vdds = size(all_possible_vdds,1); % count number of unique blockwise min_vdds we saw in faultmap input

% Set up some variables
nfb = NaN(num_possible_vdds, 1); % number of faulty blocks at each possible vdd
fractional_capacity = NaN(num_possible_vdds, 1); % fractional cache capacity on interval [0,1] at each VDD
runtime_vdds = NaN(num_vdds, 1); % index 1: nominal (highest vdd)
yield_limited = NaN(num_vdds, 1); % index 1: nominal (highest vdd)

% Compute number of faulty blocks and fractional capacity at all possible
% voltages
for i=1:num_possible_vdds
    nfb(i) = sum(sum(faultmap > all_possible_vdds(i))); % Count number of blocks that would be faulty at this voltage
    fractional_capacity(i) = (num_blocks - nfb(i)) / num_blocks;
end

% Concatenate all possible voltages, nfb, fractional_capacity for retval
voltage_possibilities = NaN(num_possible_vdds, 3);
voltage_possibilities(:,1) = all_possible_vdds;
voltage_possibilities(:,2) = nfb;
voltage_possibilities(:,3) = fractional_capacity;

% Find the runtime VDDs.
runtime_vdds(1) = nom_vdd; % nominal voltage is always the max
yield_limited(1) = 0;
for i=2:num_vdds % runtime_vdds(2) <= runtime_vdds(1), etc.
    for j=1:num_possible_vdds % Parse through all possible VDDs. Find lowest voltage
                              % that meets capacity constraint for that
                              % runtime VDD.
        if voltage_possibilities(j,3) < capacity_levels(i) % Constraint violated. Pick the next candidate voltage above it.
            if j > 1 % account for special case bounds check. If this fails, we should get a NaN returned indicating a problem.
                runtime_vdds(i) = voltage_possibilities(j-1,1);
                if runtime_vdds(i) < min_vdd % Yield min-VDD constraint.
                    runtime_vdds(i) = min_vdd;
                    yield_limited(i) = 1;
                else
                    yield_limited(i) = 0;
                end
                break;
            end
        end
    end
end

end