% run_all_figures.m
% Master script to reproduce Figures 1, 2, and Supplementary Figures from the manuscript
%
% This script sequentially runs:
%   1. Fig_1_RMT_examples.m - Random Matrix Theory examples (Figure 1)
%   2. Fig_2_single_vs_dual_adaptation_example.m - SFA vs SFA+STD example
%   3. Fig_2_fraction_excitatory_analysis.m - sensitivity analysis of local LLE change during stim due to E:I ratio changes.
%   4. Sompolinsky_N_200.m - Sompolinsky 1988 demo with N=200 (produces limit cycle)
%   5. Sompolinsky_N_1000.m - Sompolinsky 1988 demo with N=1000 (produces chaos)
%
% After each figure script, the user can review the generated figures.
% Press any key to continue to the next script.
%
% Author: Thomas J. Richner

%% Master configuration
% master_save_figs controls figure saving across all scripts:
%   'save_all_figs'          - Override all scripts to save figures
%   'save_no_figs'           - Override all scripts to NOT save figures
%   'follow_scripts_save_figs' - Let each script use its own save_figs setting
master_save_figs = 'save_no_figs';

%% Setup paths (done once for all scripts)
fprintf('=== Setting up paths ===\n');
run('StabilityAnalysis/scripts/setup_paths.m');

%% Simple Network with Dual Adaptation Demo
fprintf('\n=== Running Simple Network with Dual Adaptation ===\n');
fprintf('This demonstrates a simple SRNN with SFA + STD adaptation.\n\n');

run('StabilityAnalysis/scripts/Simple_network_with_dual_adaptation.m');

fprintf('\n--- Simple Network with Dual Adaptation complete ---\n');
fprintf('Review the figure(s), then press any key to finish...\n');
pause;
close all;

%% Figure 1: Random Matrix Theory Examples
fprintf('\n=== Running Figure 1: RMT Examples ===\n');
fprintf('This generates eigenvalue spectra for various matrix configurations.\n\n');

run('RandomMatrixTheory/Fig_1_RMT_examples.m');

fprintf('\n--- Figure 1 complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;




%% Figure 2A-F: Single vs Dual Adaptation Comparison
fprintf('\n=== Running Figure 2a-w: Single vs Dual Adaptation ===\n');
fprintf('This compares SFA-only vs SFA+STD adaptation dynamics.\n\n');

run('StabilityAnalysis/scripts/Fig_2_single_vs_dual_adaptation_example.m');

fprintf('\n--- Figure 2a-w complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

%% Figure 2G: Fraction Excitatory Analysis
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

%% Sompolinsky Chaos Demos
% Running Sompolinsky 1988 examples as a special case of our class SRNNModel.m with adaptation turned off and phi(x) = tanh(x)
% Comparing network size and gain effects on dynamics:
%   - N = 200, g = 1.8: Produces a LIMIT CYCLE (finite-size effects dominate)
%   - N = 200, g = 2.1: Produces CHAOS (higher gain overcomes finite-size effects)
%   - N = 1000, g = 1.8: Produces CHAOS (approaches infinite-N thermodynamic limit)
% The difference demonstrates how finite-size effects can qualitatively change
% the dynamics from chaos to limit cycles.

fprintf('\n=== Running Sompolinsky N = 200, g = 1.8 (Limit Cycle) ===\n');
fprintf('This demonstrates finite-size effects producing a limit cycle.\\n\n');

run('StabilityAnalysis/scripts/Sompolinsky_N_200_g_1p8.m');

fprintf('\n--- Sompolinsky N = 200, g = 1.8 complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

fprintf('\n=== Running Sompolinsky N = 200, g = 2.1 (Chaos) ===\n');
fprintf('This demonstrates higher gain producing chaos despite finite-size effects.\\n\n');

run('StabilityAnalysis/scripts/Sompolinsky_N_200_g_2p1.m');

fprintf('\n--- Sompolinsky N = 200, g = 2.1 complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

fprintf('\n=== Running Sompolinsky N = 1000, g = 1.8 (Chaos) ===\n');
fprintf('This demonstrates chaotic dynamics as N approaches thermodynamic limit.\\n\n');

run('StabilityAnalysis/scripts/Sompolinsky_N_1000_g_1p8.m');

fprintf('\n--- Sompolinsky N = 1000, g = 1.8 complete ---\n');
fprintf('Review the figure(s), then press any key to continue...\n');
pause;
close all;

%% Done
fprintf('\n=== All figures complete! ===\n');
