% run_all_figures.m
% Master script to reproduce Figures 1 and 2 from the manuscript
%
% This script sequentially runs:
%   1. Fig_1_RMT_examples.m - Random Matrix Theory examples (Figure 1)
%   2. Fig_2_single_vs_dual_adaptation_example.m - SFA vs SFA+STD comparison (Figure 2a-f)
%   3. Fig_2_fraction_excitatory_analysis.m - Parameter space analysis (Figure 2g-l)
%
% After each figure script, the user can review the generated figures.
% Press any key to continue to the next script.
%
% Author: Thomas J. Richner

%% Setup paths (done once for all scripts)
fprintf('=== Setting up paths ===\n');
run('StabilityAnalysis/scripts/setup_paths.m');

%% Figure 1: Random Matrix Theory Examples
fprintf('\n=== Running Figure 1: RMT Examples ===\n');
fprintf('This generates eigenvalue spectra for various matrix configurations.\n\n');

run('RandomMatrixTheory/Fig_1_RMT_examples.m');

fprintf('\n--- Figure 1 complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

%% Figure 2a-w: Single vs Dual Adaptation Comparison
fprintf('\n=== Running Figure 2a-w: Single vs Dual Adaptation ===\n');
fprintf('This compares SFA-only vs SFA+STD adaptation dynamics.\n\n');

run('StabilityAnalysis/scripts/Fig_2_single_vs_dual_adaptation_example.m');

fprintf('\n--- Figure 2a-w complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

%% Figure 2x-zz: Fraction Excitatory Analysis
% NOTE: Parallel Computing Toolbox is recommended but not required.
%       If unavailable, execution will fallback to serial processing.
%       Approximate runtime: ~25 minutes without parallel computing.
fprintf('\n=== Running Figure 2x-zz: Fraction Excitatory Analysis ===\n');
fprintf('This performs parameter space analysis across adaptation conditions.\n');
fprintf('NOTE: Parallel Computing Toolbox recommended (will fallback to serial).\n');
fprintf('      Approximate runtime: ~25 minutes without parallel computing.\n\n');

run('StabilityAnalysis/scripts/Fig_2_fraction_excitatory_analysis.m');


fprintf('\n--- Figure 2x-zz complete ---\n');
fprintf('Review the figure(s), then press any key to finish...\n');
pause;
close all;

%% Done
fprintf('\n=== All figures complete! ===\n');
