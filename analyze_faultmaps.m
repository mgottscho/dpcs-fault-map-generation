function [runtime_vdds, yield_limited, voltage_possibilities] = analyze_faultmaps(faultmaps, min_vdds, nom_vdd, capacity_levels, max_num_voltage_levels)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%

num_faultmaps = size(faultmaps, 3);
if size(min_vdds, 2) ~= num_faultmaps % error check
    display('Number of faultmaps must be the same in both faultmaps and min_vdds.');
    faultmaps_size = size(faultmaps)
    min_vdds_size = size(min_vdds)
    return;
end

num_runtime_voltages = size(capacity_levels, 2);
runtime_vdds = NaN(1, num_runtime_voltages, num_faultmaps);
yield_limited = NaN(1, num_runtime_voltages, num_faultmaps);
voltage_possibilities = NaN(max_num_voltage_levels, 3, num_faultmaps);

for i=1:num_faultmaps
   [runtime_vdd_fm, yield_limited_fm, voltage_possibilities_fm] = determine_runtime_vdds_for_simulation(faultmaps(:,:,i), nom_vdd, min_vdds(i), capacity_levels);
   runtime_vdds(:,:,i) = runtime_vdd_fm;
   yield_limited(:,:,i) = yield_limited_fm;
   vp_size = size(voltage_possibilities_fm);
   voltage_possibilities(1:vp_size(1),1:vp_size(2),i) = voltage_possibilities_fm;
   plot(voltage_possibilities(:,1,i), voltage_possibilities(:,3,i));
   hold on;
end


end