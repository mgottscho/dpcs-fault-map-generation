% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This script automates plotting of VDD-min distributions
% for several different cache configurations, each with many
% Monte Carlo runs.

num_MC_sims_per_cache_config = 10000;

% Aggregate all PCS results into one 3D matrix
vdd_mins_pcs = NaN(1, num_MC_sims_per_cache_config, 4);
vdd_mins_pcs(:,:,1) = vdd_mins_L1_A;
vdd_mins_pcs(:,:,2) = vdd_mins_L2_A;
vdd_mins_pcs(:,:,3) = vdd_mins_L1_B;
vdd_mins_pcs(:,:,4) = vdd_mins_L2_B;

% Aggregate all baseline (no fault tolerance) results into one 3D matrix
vdd_mins_baseline = NaN(1, num_MC_sims_per_cache_config, 4);
vdd_mins_baseline(:,:,1) = vdd_mins_nonfaulty_L1_A;
vdd_mins_baseline(:,:,2) = vdd_mins_nonfaulty_L2_A;
vdd_mins_baseline(:,:,3) = vdd_mins_nonfaulty_L1_B;
vdd_mins_baseline(:,:,4) = vdd_mins_nonfaulty_L2_B;

% Aggregate all results into one grand 3D matrix
vdd_mins_all = NaN(1, num_MC_sims_per_cache_config, 8);
vdd_mins_all(:,:,1:4) = vdd_mins_pcs;
vdd_mins_all(:,:,5:8) = vdd_mins_baseline;

% Setup consistent colors
mycolors = hsv(8);

% Plot vdd_mins_pcs distribution
figure(1);
plot_vddmin_distributions(vdd_mins_pcs, mycolors(1:4,:), {'Proposed L1-A (64KB, 4-way, 64B blocks)' 'Proposed L2-A (2MB, 8-way, 64B blocks)' 'Proposed L1-B (256KB, 8-way, 64B blocks)' 'Proposed L2-B (8MB, 16-way, 64B blocks)'});

% Plot vdd_mins_baseline distribution
figure(2);
plot_vddmin_distributions(vdd_mins_baseline, mycolors(5:8,:), {'L1-A (64KB, 4-way, 64B blocks)' 'L2-A (2MB, 8-way, 64B blocks)' 'L1-B (256KB, 8-way, 64B blocks)' 'L2-B (8MB, 16-way, 64B blocks)'});

% Plot vdd_mins_all distribution
figure(3);
plot_vddmin_distributions(all_vdd_mins, mycolors, {'Proposed L1-A (64KB, 4-way, 64B blocks)' 'Proposed L2-A (2MB, 8-way, 64B blocks)' 'Proposed L1-B (256KB, 8-way, 64B blocks)' 'Proposed L2-B (8MB, 16-way, 64B blocks)' 'L1-A (64KB, 4-way, 64B blocks)' 'L2-A (2MB, 8-way, 64B blocks)' 'L1-B (256KB, 8-way, 64B blocks)' 'L2-B (8MB, 16-way, 64B blocks)'});
