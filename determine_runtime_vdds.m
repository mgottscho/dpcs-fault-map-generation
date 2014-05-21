function [runtime_vdds, yield_limited, voltage_capacity] = determine_runtime_vdds(faultmap, vdd_min, vdd_nom, possible_vdds, capacity_levels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function determines the runtime VDD levels for architectural simulation
% given a cache faultmap.
%
% Arguments:
%   faultmap -- NumSets x Assoc Matrix: a faultmap
%   vdd_min -- Scalar: the absolute minimum VDD that the cache
%       must not go below. This is considered for yield reasons (e.g. set
%       yield constraint for DPCS -- see DAC'14 paper).
%   vdd_nom -- Scalar: the nominal VDD
%   possible_vdds -- 1xV Row Vector: the possible VDD levels that may
%       appear in any fault map. This should include nominal and min vdds.
%   capacity_levels -- 1xL Row Vector: each entry corresponds to the
%       minimum proportion of NON-faulty blocks that must be available at that
%       voltage. For example, for VDD1 requirement of at least 50%
%       non-faulty blocks, then capacity_levels(1) = 0.5.
%       
% Returns:
%   runtime_vdds -- 1xL Row Vector: each entry corresponds to a runtime
%       supply voltage for the cache. Each entry is guaranteed to meet the
%       constraints of the capacity_levels input, plus the min-VDD input.
%       These are guaranteed to be greater than or equal to
%       vdd_min, and less than or equal to vdd_nom.
%   yield_limited -- 1xL Row Vector: if any of the runtime VDDs are limited
%       by the min-VDD constraint rather than the input capacity level,
%       then the corresponding yield_limited flag will be set for that VDD level.
%   voltage_capacity -- Vx3 Matrix: Rows correspond to all
%       possible operating VDD levels as seen by their occurrences in the
%       input faultmap.
%           Column 1: the vdd level
%           Column 2: the number of faulty blocks at that vdd level
%           Column 3: the fractional cache capacity at that vdd level

% Set up some variables
L = size(capacity_levels, 2); % number of runtime vdds
V = size(possible_vdds, 2); % number of possible vdds
num_blocks = size(faultmap, 1) * size(faultmap, 2); % number of blocks in the cache
voltage_capacity = NaN(V, 3);

% Compute number of faulty blocks and fractional capacity at all possible
% vdd levels
for i=1:V % Row 1 is the highest voltage
    voltage_capacity(i,1) = possible_vdds(i); % record this voltage
    voltage_capacity(i,2) = sum(sum(faultmap > possible_vdds(i))); % Count number of blocks that would be faulty at this voltage
    voltage_capacity(i,3) = (num_blocks - voltage_capacity(i,2)) / num_blocks;
end


% Find all occurring candidate VDD levels. This is the set of blockwise
% min-VDDs found in the faultmap input.
%occurring_vdds = flipud(unique(faultmap)); % first index is highest occurring VDD

% Find the runtime VDDs.
runtime_vdds = NaN(L, 1); % Init
yield_limited = NaN(L, 1);
runtime_vdds(1) = nom_vdd; % nominal voltage is always the max
yield_limited(1) = 0;

for i=2:L
    for j=1:V % Parse through all possible VDDs. Find lowest voltage
              % that meets capacity constraint for that
              % runtime VDD.
        if voltage_capacity(j,3) < capacity_levels(i) % Constraint violated. Pick the next candidate voltage above it.
            if j > 1 % account for special case bounds check. If this fails, we should get a NaN returned indicating a problem.
                runtime_vdds(i) = voltage_capacity(j-1,1);
                if runtime_vdds(i) < vdd_min % Yield min-VDD constraint.
                    runtime_vdds(i) = vdd_min;
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