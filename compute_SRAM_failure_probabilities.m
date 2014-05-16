function [pf_cell, pf_byte, pf_halfword, pf_word, pf_doubleword, pf_64Bblock] = compute_SRAM_failure_probabilities(means, sigmas, s, n)
% Author: Mark Gottscho
% mgottscho@ucla.edu
%
% Compute the failure probability of SRAMs at various granularities and supply voltages given 
% noise margin distributions.
%
% Arguments:
%	means -- vector of means for normal distribution of SRAM SNM. Indices correspond to different VDD
%	sigmas -- vector of sigmas or normal distribution of SRAM SNM. Indices correspond to different VDD
%	s -- acceptable SNM threshold for non-faulty operation. Typically this will be set to 0.
%	n -- number of voltage levels to evaluate, should be equal to length of means and sigmas.
%
% Returns:
%	pf_cell -- probability of a single SRAM failure at each voltage level
%	pf_byte -- same, but for byte granularity (failure if at least one bit in the byte fails)
%	pf_halfword -- 16b granularity
%	pf_word -- 32b granularity
%	pf_doubleword -- 64b granularity
%	pf_64Bblock -- 512b granularity

for i = 1 : n
    pf_cell(i) = 0.75 * erfc((means(i) - s) / (sqrt(2)*sigmas(i)));
    pf_byte(i) = 1-((1-pf_cell(i))^8);
    pf_halfword(i) = 1-((1-pf_cell(i))^16);
    pf_word(i) = 1-((1-pf_cell(i))^32);
    pf_doubleword(i) = 1-((1-pf_cell(i))^64);
    pf_64Bblock(i) = 1-((1-pf_cell(i))^512);
end
