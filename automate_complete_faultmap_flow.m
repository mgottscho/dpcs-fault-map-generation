% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This script automates semi-parallel processing of many, many fault maps
% for different cache configurations.
% It saves .mat files for each set of cache results.

% Read in the voltage parameter files
display('Reading in voltage parameter files...');
vdd_block_fault_cdf_L1_A = parse_voltage_parameter_file('parameters/gem5params-L1-A.csv');
vdd_block_fault_cdf_L2_A = parse_voltage_parameter_file('parameters/gem5params-L2-A.csv');
vdd_block_fault_cdf_L1_B = parse_voltage_parameter_file('parameters/gem5params-L1-B.csv');
vdd_block_fault_cdf_L2_B = parse_voltage_parameter_file('parameters/gem5params-L2-B.csv');

% Set up cache dimensions
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
N=10000; % Number of Monte Carlo runs per cache config

display(['Generating ' num2str(N) ' L1-A fault maps...']);
[faultmaps_L1_A, vdd_mins_L1_A, vdd_mins_nofaults_L1_A] = generate_faultmap_group(vdd_block_fault_cdf_L1_A, cache_size_bits_L1_A, associativity_L1_A, bits_per_block_L1_A, N);

display(['Generating ' num2str(N) ' L2-A fault maps...']);
[faultmaps_L2_A, vdd_mins_L2_A, vdd_mins_nofaults_L2_A] = generate_faultmap_group(vdd_block_fault_cdf_L2_A, cache_size_bits_L2_A, associativity_L2_A, bits_per_block_L2_A, N);

display(['Generating ' num2str(N) ' L1-B fault maps...']);
[faultmaps_L1_B, vdd_mins_L1_B, vdd_mins_nofaults_L1_B] = generate_faultmap_group(vdd_block_fault_cdf_L1_B, cache_size_bits_L1_B, associativity_L1_B, bits_per_block_L1_B, N);

display(['Generating ' num2str(N) ' L2-B fault maps...']);
[faultmaps_L2_B, vdd_mins_L2_B, vdd_mins_nofaults_L2_B] = generate_faultmap_group(vdd_block_fault_cdf_L2_B, cache_size_bits_L2_B, associativity_L2_B, bits_per_block_L2_B, N);

% Plot the vdd_mins results
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
%figure(2);
%plot_block_vdd_mins(faultmaps_L2_A, vdd_block_fault_cdf_L2_A);
%figure(3);
%plot_block_vdd_mins(faultmaps_L1_B, vdd_block_fault_cdf_L1_B);
%figure(4);
%plot_block_vdd_mins(faultmaps_L2_B, vdd_block_fault_cdf_L2_B);
%figure(5);
plot_vdd_mins_distribution(vdd_mins_all, mycolors, {'Proposed L1-A (64KB, 4-way, 64B blocks)' 'Proposed L2-A (2MB, 8-way, 64B blocks)' 'Proposed L1-B (256KB, 8-way, 64B blocks)' 'Proposed L2-B (8MB, 16-way, 64B blocks)' 'L1-A (64KB, 4-way, 64B blocks)' 'L2-A (2MB, 8-way, 64B blocks)' 'L1-B (256KB, 8-way, 64B blocks)' 'L2-B (8MB, 16-way, 64B blocks)'});

% Get faultmap percentile indices for gem5 simulation
percentiles = [0.0001 0.25 0.50 0.75 1.0];
selected_indices_L1_A = get_percentile_faultmaps(vdd_mins_L1_A, percentiles);
selected_indices_L2_A = get_percentile_faultmaps(vdd_mins_L2_A, percentiles);
selected_indices_L1_B = get_percentile_faultmaps(vdd_mins_L1_B, percentiles);
selected_indices_L2_B = get_percentile_faultmaps(vdd_mins_L2_B, percentiles);

% Determine runtime VDDs
% TO-DO