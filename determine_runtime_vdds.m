function [runtime_vdds, yield_limited, voltage_capacities] = determine_runtime_vdds(faultmaps, vdd_mins, vdd_nom, possible_vdds, capacity_levels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This function determines the runtime VDD levels for architectural simulation
% given a cache faultmap.
%
% Arguments:
%   faultmaps -- NumSets x Assoc x N Matrix: set of faultmaps
%   vdd_mins -- 1xN Row Vector: the absolute minimum VDDs that respective
%       faultmaps must not go below. This is considered for yield reasons (e.g. set
%       yield constraint for DPCS -- see DAC'14 paper).
%   vdd_nom -- Scalar: the nominal VDD for all input faultmaps
%   possible_vdds -- 1xV Row Vector: the possible VDD levels that may
%       appear in any input fault map. This should include nominal and min vdds.
%   capacity_levels -- 1xL Row Vector: each entry corresponds to the
%       minimum proportion of NON-faulty blocks that must be available at that
%       voltage. For example, for VDD1 requirement of at least 50%
%       non-faulty blocks, then capacity_levels(1) = 0.5.
%       
% Returns:
%   runtime_vdds -- 1xLxN Matrix: each element in a Z-plane corresponds to a runtime
%       supply voltage for the respective faultmap. Each entry is guaranteed to meet the
%       constraints of the capacity_levels input, plus the min-VDD input.
%       These are guaranteed to be greater than or equal to
%       vdd_min, and less than or equal to vdd_nom.
%   yield_limited -- 1xLxN Matrix: if any of the runtime VDDs are limited
%       by the min-VDD constraint rather than the input capacity level,
%       then the corresponding yield_limited flag will be set for that VDD level.
%   voltage_capacities -- Vx3xN Matrix: Rows correspond to all
%       possible operating VDD levels as seen by their occurrences in the
%       input faultmap.
%           Column 1: the vdd level
%           Column 2: the number of faulty blocks at that vdd level
%           Column 3: the fractional cache capacity at that vdd level

% Set up some variables
N = size(faultmaps, 3);
L = size(capacity_levels, 2); % number of runtime vdds
V = size(possible_vdds, 2); % number of possible vdds
num_blocks = size(faultmaps, 1) * size(faultmaps, 2); % number of blocks in a faultmap
voltage_capacities = NaN(V, 3, N);
runtime_vdds = NaN(L, 1, N); 
yield_limited = NaN(L, 1, N);

% error check
if N ~= size(vdd_mins, 2)
    display('Number of faultmaps and number of VDD mins must be equal!');
    faultmaps_size = size(faultmaps)
    vdd_mins_size = size(vdd_mins)
    return;
end

% Compute number of faulty blocks and fractional capacity at all possible
% vdd levels
% for i=1:V % Row 1 is the highest voltage
%     voltage_capacity(i,1) = possible_vdds(i); % record this voltage
%     voltage_capacity(i,2) = sum(sum(faultmap > possible_vdds(i))); % Count number of blocks that would be faulty at this voltage
%     voltage_capacity(i,3) = (num_blocks - voltage_capacity(i,2)) / num_blocks;
% end

% loop over all faultmaps
for i=1:N
    % loop over all voltages
    for j=1:V
        voltage_capacities(j,1,i) = possible_vdds(j); % record voltages
        voltage_capacities(j,2,i) = sum(sum(faultmaps(:,:,i) > possible_vdds(j))); % Count number of blocks that would be faulty at each voltage
        voltage_capacities(j,3,i) = (num_blocks - voltage_capacities(j,2,i)) / num_blocks; % compute effective capacity at each voltage
    end
end
    
% Find the runtime VDDs.
runtime_vdds(1,1,:) = vdd_nom; % nominal voltage is always the max
yield_limited(1,1,:) = 0;

for i=1:N % Loop over each faultmap
    for j=2:L % Loop over each capacity level
        for k=1:V % Loop over each possible voltage level
            % Find lowest voltage
            % that meets capacity constraint for that
            % runtime VDD.
            if voltage_capacities(k,3,i) < capacity_levels(j) % Constraint violated. Pick the next candidate voltage above it.
                if j > 1 % account for special case bounds check. If this fails, we should get a NaN returned indicating a problem.
                    runtime_vdds(j,1,i) = voltage_capacities(k-1,1,i);
                    if runtime_vdds(j,1,i) < vdd_mins(i) % Yield min-VDD constraint.
                        runtime_vdds(j,1,i) = vdd_mins(i);
                        yield_limited(j,1,i) = 1;
                    else
                        yield_limited(j,1,i) = 0;
                    end
                    break;
                end
            end
        end
    end
end

end