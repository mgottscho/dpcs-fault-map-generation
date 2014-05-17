% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% This script automates semi-parallel processing of many, many fault maps
% for different cache configurations.
% It saves .mat files for each cache results.
% By default, it is not saving CSV files of the faultmaps since they consume many GB!


start_index = 1;
end_index = 10000;

mkdir faultmaps

% Compute L1-A fault maps
display('L1-A fault maps...');
[block_faultmaps_L1_A, vdd_mins_L1_A, vdd_mins_nonfaulty_L1_A] = generate_fault_maps('parameters/gem5params-L1-A.csv', 64*2^10*8, 4, 512, [start_index:end_index], 0, 'faultmaps', 'L1', 'A');
save('faultmaps/faultmaps_L1_A.mat', '-v7.3');
clear block_faultmaps_L1_A;
clear vdd_mins_L1_A;
clear vdd_mins_nonfaulty_L1_A;

% Compute L2-A fault maps
display('L2-A fault maps...');
[block_faultmaps_L2_A, vdd_mins_L2_A, vdd_mins_nonfaulty_L2_A] = generate_fault_maps('parameters/gem5params-L2-A.csv', 2*2^20*8, 8, 512, [start_index:end_index], 0, 'faultmaps', 'L2', 'A');
save('faultmaps/faultmaps_L2_A.mat', '-v7.3');
clear block_faultmaps_L2_A;
clear vdd_mins_L2_A;
clear vdd_mins_nonfaulty_L2_A;
 
% Compute L1-B fault maps
display('L1-B fault maps...');
[block_faultmaps_L1_B, vdd_mins_L1_B, vdd_mins_nonfaulty_L1_B] = generate_fault_maps('parameters/gem5params-L1-B.csv', 256*2^10*8, 8, 512, [start_index:end_index], 0, 'faultmaps', 'L1', 'B');
 save('faultmaps/faultmaps_L1_B.mat', '-v7.3');
clear block_faultmaps_L1_B;
clear vdd_mins_L1_B;
clear vdd_mins_nonfaulty_L1_B;
 
% Compute L2-B fault maps
display('L2-B fault maps...');
[block_faultmaps_L2_B, vdd_mins_L2_B, vdd_mins_nonfaulty_L2_B] = generate_fault_maps('parameters/gem5params-L2-B.csv', 8*2^20*8, 16, 512, [start_index:end_index], 0, 'faultmaps', 'L2', 'B');
save('faultmaps/faultmaps_L2_B.mat', '-v7.3');
clear block_faultmaps_L2_B;
clear vdd_mins_L2_B;
clear vdd_mins_nonfaulty_L2_B;

display('DONE!!!!!!');
