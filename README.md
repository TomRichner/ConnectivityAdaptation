# ConnectivityAdaptation
Matlab code to reproduce figures for "Adaptation modulates effective connectivity and network stability" by Thomas J. Richner, Martynas Dervinis, and Brian N. Lundstrom

This repo is an organized subset and fixed snapshot of two other repos:
https://github.com/TomRichner/RandomMatrixTheory
https://github.com/TomRichner/FractionalReservoir

The code here reproduces the two main figures in 
"Adaptation modulates effective connectivity and network stability"

## RandomMatrixTheory
RMT_examples.m creates figure 1
RMT.m is a class for analyzing sparse random matrices based on Harris et al. 2023

## ConnectivityAdaptation
scripts/setup_paths.m sets the paths so that Matlab knows where to find the code for figure 2
scripts/Fig_2_single_vs_dual_adaptation_example.m makes the example time series to see the effect of adaptation and stimulation
scripts/Fig_2_fraction_excitatory_analysis.m runs the experiment 25 times for statistical analysis and generates more subfigures.