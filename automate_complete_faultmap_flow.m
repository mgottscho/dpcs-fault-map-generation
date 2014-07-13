% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This script automates semi-parallel processing of many, many fault maps
% for different cache configurations.
% It saves .mat files for each set of cache results.

N = 10000; % Number of Monte Carlo faultmaps per cache config
vdd_nom = 1000; % Not used by fault map generation, just runtime VDD part
vdd_increment = 10; % Not used by fault map generation, just runtime VDD part
capacity_levels = [1 0.99 0.75]; % Runtime VDD levels for each cache should be set to meet these fractional capacity constraints

% Read in the voltage parameter files
display('Reading in voltage parameter files...');
[vdd_block_fault_cdf_L1_A, vdd_power_energy_L1_A] = parse_voltage_parameter_file('parameters/fmparams-L1-A.csv');
[vdd_block_fault_cdf_L2_A, vdd_power_energy_L2_A] = parse_voltage_parameter_file('parameters/fmparams-L2-A.csv');
[vdd_block_fault_cdf_L1_B, vdd_power_energy_L1_B] = parse_voltage_parameter_file('parameters/fmparams-L1-B.csv');
[vdd_block_fault_cdf_L2_B, vdd_power_energy_L2_B] = parse_voltage_parameter_file('parameters/fmparams-L2-B.csv');

% Set up cache dimensions -- FIXME: These should probably be input
% parameters
display('Configuring cache dimensions...');
cache_size_bits_L1_A = 64*2^10*8;
cache_size_bits_L2_A = 2*2^20*8;
cache_size_bits_L1_B = 256*2^10*8;
cache_size_bits_L2_B = 8*2^20*8;

associativity_L1_A = 4;
associativity_L2_A = 8;
associativity_L1_B = 8;
associativity_L2_B = 16;

bits_per_block_L1_A = 512;
bits_per_block_L2_A = 512;
bits_per_block_L1_B = 512;
bits_per_block_L2_B = 512;

display(['L1-A: ' num2str(cache_size_bits_L1_A) 'b -- ' num2str(associativity_L1_A) '-way -- ' num2str(bits_per_block_L1_A) ' b/block']);
display(['L2-A: ' num2str(cache_size_bits_L2_A) 'b -- ' num2str(associativity_L2_A) '-way -- ' num2str(bits_per_block_L2_A) ' b/block']);
display(['L1-B: ' num2str(cache_size_bits_L1_B) 'b -- ' num2str(associativity_L1_B) '-way -- ' num2str(bits_per_block_L1_B) ' b/block']);
display(['L2-B: ' num2str(cache_size_bits_L2_B) 'b -- ' num2str(associativity_L2_B) '-way -- ' num2str(bits_per_block_L2_B) ' b/block']);

% Generate fault maps

display(['Generating ' num2str(N) ' L1-A fault maps...']);
[faultmaps_L1_A, vdd_mins_L1_A, vdd_mins_nofaults_L1_A] = generate_faultmap_group(vdd_block_fault_cdf_L1_A, cache_size_bits_L1_A, associativity_L1_A, bits_per_block_L1_A, N);

display(['Generating ' num2str(N) ' L2-A fault maps...']);
[faultmaps_L2_A, vdd_mins_L2_A, vdd_mins_nofaults_L2_A] = generate_faultmap_group(vdd_block_fault_cdf_L2_A, cache_size_bits_L2_A, associativity_L2_A, bits_per_block_L2_A, N);

display(['Generating ' num2str(N) ' L1-B fault maps...']);
[faultmaps_L1_B, vdd_mins_L1_B, vdd_mins_nofaults_L1_B] = generate_faultmap_group(vdd_block_fault_cdf_L1_B, cache_size_bits_L1_B, associativity_L1_B, bits_per_block_L1_B, N);

display(['Generating ' num2str(N) ' L2-B fault maps...']);
[faultmaps_L2_B, vdd_mins_L2_B, vdd_mins_nofaults_L2_B] = generate_faultmap_group(vdd_block_fault_cdf_L2_B, cache_size_bits_L2_B, associativity_L2_B, bits_per_block_L2_B, N);

% Plot the vdd_mins results
display('Plotting min-VDD histograms...');
vdd_mins_pcs = NaN(1, N, 4); % Aggregate all PCS results into one 3D matrix
vdd_mins_pcs(:,:,1) = vdd_mins_L1_A;
vdd_mins_pcs(:,:,2) = vdd_mins_L2_A;
vdd_mins_pcs(:,:,3) = vdd_mins_L1_B;
vdd_mins_pcs(:,:,4) = vdd_mins_L2_B;

vdd_mins_baseline = NaN(1, N, 4); % Aggregate all baseline (no fault tolerance) results into one 3D matrix
vdd_mins_baseline(:,:,1) = vdd_mins_nofaults_L1_A;
vdd_mins_baseline(:,:,2) = vdd_mins_nofaults_L2_A;
vdd_mins_baseline(:,:,3) = vdd_mins_nofaults_L1_B;
vdd_mins_baseline(:,:,4) = vdd_mins_nofaults_L2_B;

vdd_mins_all = NaN(1, N, 8); % Aggregate all results into one grand 3D matrix
vdd_mins_all(:,:,1:4) = vdd_mins_pcs;
vdd_mins_all(:,:,5:8) = vdd_mins_baseline;
clear vdd_mins_pcs;
clear vdd_mins_baseline;

mycolors = hsv(8); % Setup consistent colors

figure(1);
plot_block_vdd_mins(faultmaps_L1_A, vdd_block_fault_cdf_L1_A);
% figure(2);
% plot_block_vdd_mins(faultmaps_L2_A, vdd_block_fault_cdf_L2_A);
% figure(3);
% plot_block_vdd_mins(faultmaps_L1_B, vdd_block_fault_cdf_L1_B);
% figure(4);
% plot_block_vdd_mins(faultmaps_L2_B, vdd_block_fault_cdf_L2_B);
figure(2);
plot_vdd_mins_distribution(vdd_mins_all, mycolors, {'Proposed L1-A (64KB, 4-way, 64B blocks)' 'Proposed L2-A (2MB, 8-way, 64B blocks)' 'Proposed L1-B (256KB, 8-way, 64B blocks)' 'Proposed L2-B (8MB, 16-way, 64B blocks)' 'L1-A (64KB, 4-way, 64B blocks)' 'L2-A (2MB, 8-way, 64B blocks)' 'L1-B (256KB, 8-way, 64B blocks)' 'L2-B (8MB, 16-way, 64B blocks)'});
clear vdd_mins_all;

% Get percentile faultmaps for gem5 simulation
display('Selecting faultmaps for gem5 simulation...');
percentiles = [0.0001 0.25 0.50 0.75 1.0];
selected_indices_L1_A = get_percentile_faultmaps(vdd_mins_L1_A, percentiles);
selected_indices_L2_A = get_percentile_faultmaps(vdd_mins_L2_A, percentiles);
selected_indices_L1_B = get_percentile_faultmaps(vdd_mins_L1_B, percentiles);
selected_indices_L2_B = get_percentile_faultmaps(vdd_mins_L2_B, percentiles);

selected_faultmaps_L1_A = faultmaps_L1_A(:,:,selected_indices_L1_A);
selected_faultmaps_L2_A = faultmaps_L2_A(:,:,selected_indices_L2_A);
selected_faultmaps_L1_B = faultmaps_L1_B(:,:,selected_indices_L1_B);
selected_faultmaps_L2_B = faultmaps_L2_B(:,:,selected_indices_L2_B);

selected_vdd_mins_L1_A = vdd_mins_L1_A(selected_indices_L1_A);
selected_vdd_mins_L2_A = vdd_mins_L2_A(selected_indices_L2_B);
selected_vdd_mins_L1_B = vdd_mins_L1_B(selected_indices_L1_A);
selected_vdd_mins_L2_B = vdd_mins_L2_B(selected_indices_L2_B);

% Determine runtime VDDs
display('Determining runtime VDDs for simulation...');
[runtime_vdds_L1_A, yield_limited_L1_A, voltage_capacities_power_energy_L1_A] = determine_runtime_vdds(selected_faultmaps_L1_A, selected_vdd_mins_L1_A, vdd_nom, vdd_nom:-vdd_increment:100, capacity_levels, vdd_power_energy_L1_A);
[runtime_vdds_L2_A, yield_limited_L2_A, voltage_capacities_power_energy_L2_A] = determine_runtime_vdds(selected_faultmaps_L2_A, selected_vdd_mins_L2_A, vdd_nom, vdd_nom:-vdd_increment:100, capacity_levels, vdd_power_energy_L2_A);
[runtime_vdds_L1_B, yield_limited_L1_B, voltage_capacities_power_energy_L1_B] = determine_runtime_vdds(selected_faultmaps_L1_B, selected_vdd_mins_L1_B, vdd_nom, vdd_nom:-vdd_increment:100, capacity_levels, vdd_power_energy_L1_B);
[runtime_vdds_L2_B, yield_limited_L2_B, voltage_capacities_power_energy_L2_B] = determine_runtime_vdds(selected_faultmaps_L2_B, selected_vdd_mins_L2_B, vdd_nom, vdd_nom:-vdd_increment:100, capacity_levels, vdd_power_energy_L2_B);

% Export selected faultmaps for gem5 simulation
display('Exporting CSVs for selected faultmaps...');
mkdir('faultmaps');
export_faultmaps(selected_faultmaps_L1_A, selected_indices_L1_A, 'faultmaps', 'L1', 'A');
export_faultmaps(selected_faultmaps_L2_A, selected_indices_L2_A, 'faultmaps', 'L2', 'A');
export_faultmaps(selected_faultmaps_L1_B, selected_indices_L1_B, 'faultmaps', 'L1', 'B');
export_faultmaps(selected_faultmaps_L2_B, selected_indices_L2_B, 'faultmaps', 'L2', 'B');
export_runtime_vdds(runtime_vdds_L1_A, voltage_capacities_power_energy_L1_A, selected_indices_L1_A, 'faultmaps', 'L1', 'A');
export_runtime_vdds(runtime_vdds_L2_A, voltage_capacities_power_energy_L2_A, selected_indices_L2_A, 'faultmaps', 'L2', 'A');
export_runtime_vdds(runtime_vdds_L1_B, voltage_capacities_power_energy_L1_B, selected_indices_L1_B, 'faultmaps', 'L1', 'B');
export_runtime_vdds(runtime_vdds_L2_B, voltage_capacities_power_energy_L2_B, selected_indices_L2_B, 'faultmaps', 'L2', 'B');

display('DONE!');