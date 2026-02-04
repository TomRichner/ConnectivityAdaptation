% close all; clear all; clc;  % Commented out for master script compatibility
% setup_paths();  % Commented out - called by master script

% Derive project root from script location for portable paths
script_path = fileparts(mfilename('fullpath'));
project_root = fileparts(script_path);  % Go up from scripts/ to project root
figs_root = fullfile(project_root, 'figs');
output_folder_name = ['srnn_comparison_', datestr(now, 'yyyymmdd_HHMM')];

set(groot, 'DefaultFigureColor', 'white');
set(groot, 'DefaultAxesFontSize', 14);
set(groot, 'DefaultTextFontSize', 14);
set(groot, 'DefaultLineLineWidth', 0.75);
set(groot, 'DefaultAxesLineWidth', 2);
set(groot, 'DefaultAxesTitleFontWeight', 'normal');

% NOTE: This script sets global MATLAB figure defaults that persist for the session.
% Run `reset(groot)` afterward to restore factory defaults if needed.

% Check for master override from run_all_figures.m
if exist('master_save_figs', 'var')
    if strcmp(master_save_figs, 'save_all_figs')
        save_figs = true;
    elseif strcmp(master_save_figs, 'save_no_figs')
        save_figs = false;
    end
end
if ~exist('save_figs', 'var')
    save_figs = false;  % Script default
end
save_workspace = false;

%% Shared simulation parameters
level_of_chaos = 1.0; % gamma from Sompolinsky

u_ex_scale = 1; % can change scale of stimulus.

rng_seeds = [42 42]; % seed 1 is for connection matrix, seed 2 is for stimulus

time_config.J_periods = [false true true];  % three periods: no-stim, stim, no-stim
time_config.T_range = [-15, 45]; % seconds
time_config.T_plot = [7.5, 45];  % seconds. Trim off half of first no-stim period

combined_runs = {}; % cell array to hold multiple simulations

%% Run 1: spike frequency adaptation (SFA) only
close all;
note = 'SFA_only';

n_a_E = 3; % three timeconstants of SFA
n_b_E = 0; % no short-term synaptic depression

save_dir = fullfile(figs_root, output_folder_name, note);
fprintf('Running SRNN with u_ex_scale=%g, n_a_E=%d, n_b_E=%d, level_of_chaos=%g\n', u_ex_scale, n_a_E, n_b_E, level_of_chaos);

% Create and configure SRNNModel
model = SRNNModel();

% Network architecture (exactly matching full_SRNN_run_SRNNModel.m)
model.n = 300;
model.indegree = 100;
model.f = 0.50;
model.tau_d = 0.1;
model.c_E = 0.25/3;

% RMT tilde-notation parameters (Harris 2023)
% F = 1/sqrt(N*alpha*(2-alpha)), the scaling factor yielding R=1 when
% all tilde parameters are equal (see parameter_table.md)
F = model.default_val;
model.mu_E_tilde = 3.5*F;
model.mu_I_tilde = -3.5*F;
model.sigma_E_tilde = F;
model.sigma_I_tilde = F;
model.E_W = -0.5 * F;
model.zrs_mode = 'none';

model.level_of_chaos = level_of_chaos;
model.rescale_by_abscissa = false;

% Adaptation parameters
model.n_a_E = n_a_E;
model.n_a_I = 0;
model.tau_a_E = logspace(log10(0.1), log10(10), n_a_E);

% STD parameters
model.n_b_E = n_b_E;
model.n_b_I = 0;
model.tau_b_E_rec = 1;
model.tau_b_E_rel = 0.5;

% Activation function
S_a = 0.9;
S_c = 0.40;
model.S_a = S_a;
model.S_c = S_c;
model.activation_function = @(x) piecewiseSigmoid(x, S_a, S_c);
model.activation_function_derivative = @(x) piecewiseSigmoidDerivative(x, S_a, S_c);

% Simulation settings
model.T_range = time_config.T_range;
model.T_plot = time_config.T_plot;
model.rng_seeds = rng_seeds;
model.u_ex_scale = u_ex_scale;

% Lyapunov settings
model.lya_method = 'benettin';
model.filter_local_lya = true;
model.store_full_state = true;

% Input configuration
model.input_config.n_steps = 3;
model.input_config.positive_only = true;
model.input_config.step_density_E = 0.15;
model.input_config.step_density_I = 0;
model.input_config.amp = 0.5;
model.input_config.no_stim_pattern = false(1, 3);
model.input_config.no_stim_pattern(1:2:end) = true;
model.input_config.intrinsic_drive = 0 * ones(model.n, 1);

% Build and run model
model.build();
model.run();

% Extract outputs for compatibility
t_out_1 = model.t_out;
S_out_1 = model.S_out;
params_1 = model.get_params();
lya_1 = model.lya_results;
plot_data_1 = model.plot_data;

% Plot time series
model.plot();

% Plot Jacobian eigenvalues, W matrix, histograms, J_eff, colorbars
plot_jacobian_eigenvalues_fig(model, params_1, time_config);
plot_W_matrix_fig(model);
plot_weight_histogram_fig(model, params_1);
plot_J_eff_matrices_fig(model, S_out_1, t_out_1, params_1, time_config);
plot_W_colorbar_fig();
plot_J_eff_colorbar_fig();

run1.plot_data = plot_data_1;
run1.params = params_1;
run1.lya_results = lya_1;
run1.Lya_method = 'benettin';
combined_runs{1} = run1;

%% Run 2: SFA + STD
note = 'STD_and_SFA';
n_a_E = 3;
n_b_E = 1;

save_dir = fullfile(figs_root, output_folder_name, note);
fprintf('Running SRNN with u_ex_scale=%g, n_a_E=%d, n_b_E=%d, level_of_chaos=%g\n', u_ex_scale, n_a_E, n_b_E, level_of_chaos);

% Create and configure SRNNModel (same as Run 1, except n_b_E = 1)
model = SRNNModel();

model.n = 300;
model.indegree = 100;
model.f = 0.50;
model.tau_d = 0.1;
model.c_E = 0.25/3;

F = model.default_val;
model.mu_E_tilde = 3.5*F;
model.mu_I_tilde = -3.5*F;
model.sigma_E_tilde = F;
model.sigma_I_tilde = F;
model.E_W = -0.5 * F;
model.zrs_mode = 'none';

model.level_of_chaos = level_of_chaos;
model.rescale_by_abscissa = false;

model.n_a_E = n_a_E;
model.n_a_I = 0;
model.tau_a_E = logspace(log10(0.1), log10(10), n_a_E);

model.n_b_E = n_b_E;  % KEY DIFFERENCE: 1 instead of 0
model.n_b_I = 0;
model.tau_b_E_rec = 1;
model.tau_b_E_rel = 0.5;

S_a = 0.9;
S_c = 0.40;
model.S_a = S_a;
model.S_c = S_c;
model.activation_function = @(x) piecewiseSigmoid(x, S_a, S_c);
model.activation_function_derivative = @(x) piecewiseSigmoidDerivative(x, S_a, S_c);

model.T_range = time_config.T_range;
model.T_plot = time_config.T_plot;
model.rng_seeds = rng_seeds;
model.u_ex_scale = u_ex_scale;

model.lya_method = 'benettin';
model.filter_local_lya = true;
model.store_full_state = true;

model.input_config.n_steps = 3;
model.input_config.positive_only = true;
model.input_config.step_density_E = 0.15;
model.input_config.step_density_I = 0;
model.input_config.amp = 0.5;
model.input_config.no_stim_pattern = false(1, 3);
model.input_config.no_stim_pattern(1:2:end) = true;
model.input_config.intrinsic_drive = 0 * ones(model.n, 1);

model.build();
model.run();

t_out_4 = model.t_out;
S_out_4 = model.S_out;
params_4 = model.get_params();
lya_4 = model.lya_results;
plot_data_4 = model.plot_data;

model.plot();

plot_jacobian_eigenvalues_fig(model, params_4, time_config);
plot_W_matrix_fig(model);
plot_weight_histogram_fig(model, params_4);
plot_J_eff_matrices_fig(model, S_out_4, t_out_4, params_4, time_config);
plot_W_colorbar_fig();
plot_J_eff_colorbar_fig();

run4.plot_data = plot_data_4;
run4.params = params_4;
run4.lya_results = lya_4;
run4.Lya_method = 'benettin';
combined_runs{2} = run4;

%% Plot Combined
[fig_handle, ~] = plot_SRNN_combined_tseries(combined_runs, 3, {'u_ex', 'x', 'br', 'a', 'b', 'lya'});

% Add letters to subplots
AddLetters2Plots(fig_handle, {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'}, 'FontSize', 16, 'FontWeight', 'normal', 'HShift', -0.06, 'VShift', -0.02);

ylim([-1.9 1.9]) % y limits of the local lyapunov exponent

if save_figs
    save_dir_combined = fullfile(figs_root, output_folder_name);
    save_name_base = 'combined_comparison';

    % Use the existing helper function
    save_some_figs_to_folder_2(save_dir_combined, save_name_base, [], {'fig', 'svg', 'png', 'jp2'});
    fprintf('Combined plot saved to %s\n', save_dir_combined);
end


%% ==================== LOCAL FUNCTIONS ====================

function plot_jacobian_eigenvalues_fig(model, params, time_config)
%PLOT_JACOBIAN_EIGENVALUES_FIG Compute and plot Jacobian eigenvalues at sample times

t_out = model.t_out;
S_out = model.S_out;

T_stim = time_config.T_range(2);
n_steps = model.input_config.n_steps;
step_period = fix(T_stim / n_steps);

if isfield(time_config, 'J_periods')
    J_periods = time_config.J_periods;
else
    J_periods = true(1, n_steps);
end

J_times_sec = [];
for k = 1:n_steps
    if J_periods(k)
        t_center = (k-1)*step_period + step_period/2;
        J_times_sec = [J_times_sec, t_center];
    end
end

J_times = round((J_times_sec - t_out(1)) * model.fs) + 1;
J_times = unique(J_times);

fprintf('Computing Jacobian at %d time points...\n', length(J_times));
J_array = compute_Jacobian_at_indices(S_out, J_times, params);

eigenvalues_all = cell(length(J_times), 1);
for idx = 1:length(J_times)
    eigenvalues_all{idx} = eig(J_array(:,:,idx));
end

n_J_plots = length(J_times);
n_total_plots = 1 + n_J_plots;
if n_total_plots <= 4
    n_rows = 1;
    n_cols = n_total_plots;
else
    n_cols = ceil(sqrt(n_total_plots));
    n_rows = ceil(n_total_plots / n_cols);
end

figure('Position', [1312, 526, 1100, 600]);
ax_handles = zeros(n_total_plots, 1);

% Hard-coded global axis limits (matched between SFA and SFA+STD)
global_xlim = [-55, 15.6];
global_ylim = [-26, 26];

% Subplot 1: eigenspectra of static I-W
ax_handles(1) = subplot(n_rows, n_cols, 1);
eigs_diff = 1/model.tau_d*eig(-eye(params.n) + model.W);

circle_center = -1 / model.tau_d;
circle_radius = model.R / model.tau_d;
circle_params = struct('center', circle_center, 'radius', circle_radius);

ax_handles(1) = plot_eigenvalues(eigs_diff, ax_handles(1), 0, global_xlim, global_ylim, circle_params);
set(ax_handles(1), 'Color', 'none');

% Subplots 2+: Jacobian eigenvalues at each time point
for i_plot = 1+(1:n_J_plots)
    ax_handles(i_plot) = subplot(n_rows, n_cols, i_plot);
    evals = eigenvalues_all{i_plot-1};
    time_val = t_out(J_times(i_plot-1));
    ax_handles(i_plot) = plot_eigenvalues(evals, ax_handles(i_plot), time_val, global_xlim, global_ylim);
    set(ax_handles(i_plot), 'Color', 'none');
end

linkaxes(ax_handles, 'xy');
end

function plot_W_matrix_fig(model)
%PLOT_W_MATRIX_FIG Plot static W matrix with imagesc

W_plot = full(model.W);

figure('Position', [1312, 940, 600, 310]);
subplot(1, 1, 1);
imagesc(W_plot);
colormap(redwhiteblue_colormap(256));
clim([-0.5, 0.5]);  % Hard-coded clim for W
axis square;
set(gca, 'XTick', [], 'YTick', []);
box off;
set(gca, 'Color', 'none');
set(gca, 'XColor', 'white', 'YColor', 'white', 'Layer', 'bottom');
end

function plot_weight_histogram_fig(model, params)
%PLOT_WEIGHT_HISTOGRAM_FIG Histogram of E and I synaptic weights

W_E = full(model.W(:, params.E_indices));
W_E_nonzero = W_E(W_E ~= 0);

W_I = full(model.W(:, params.I_indices));
W_I_nonzero = W_I(W_I ~= 0);

all_weights = [W_E_nonzero(:); W_I_nonzero(:)];
n_bins = 50;
bin_edges = linspace(min(all_weights), max(all_weights), n_bins + 1);

figure('Position', [100, 500, 400, 250]);
hold on;
histogram(W_E_nonzero, bin_edges, 'FaceColor', [0.8 0.2 0.2], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
histogram(W_I_nonzero, bin_edges, 'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
hold off;

xlabel('Weight');
ylabel('Count');
lg = legend('E', 'I', 'Location', 'northeast');
lg.Position(1) = lg.Position(1) + 0.08;
legend boxoff;
set(gca, 'Color', 'none');
box off;

% Add mu_tilde markers on x-axis
ax = gca;
y_bottom = ax.YLim(1);
mu_E_pos = model.mu_E_tilde + model.E_W;
mu_I_pos = model.mu_I_tilde + model.E_W;
text(mu_E_pos, y_bottom, '$\tilde{\mu}_E$', 'Interpreter', 'latex', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10);
text(mu_I_pos, y_bottom, '$\tilde{\mu}_I$', 'Interpreter', 'latex', ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'FontSize', 10);
end

function plot_J_eff_matrices_fig(model, S_out, t_out, params, time_config)
%PLOT_J_EFF_MATRICES_FIG Compute and plot J_eff at sample times

T_stim = time_config.T_range(2);
n_steps = model.input_config.n_steps;
step_period = fix(T_stim / n_steps);

if isfield(time_config, 'J_periods')
    J_periods = time_config.J_periods;
else
    J_periods = true(1, n_steps);
end

J_times_sec = [];
for k = 1:n_steps
    if J_periods(k)
        t_center = (k-1)*step_period + step_period/2;
        J_times_sec = [J_times_sec, t_center];
    end
end

J_times = round((J_times_sec - t_out(1)) * model.fs) + 1;
J_times = unique(J_times);

n_J_plots = length(J_times);
if n_J_plots <= 4
    n_rows = 1;
    n_cols = n_J_plots;
else
    n_cols = ceil(sqrt(n_J_plots));
    n_rows = ceil(n_J_plots / n_cols);
end

fprintf('Computing J_eff at %d time points...\n', length(J_times));

J_eff_array = zeros(params.n, params.n, length(J_times));
for idx = 1:length(J_times)
    J_eff_array(:,:,idx) = full(compute_J_eff(S_out(J_times(idx),:)', params));
end

figure('Position', [100, 100, 600, 310]);
for i_plot = 1:n_J_plots
    subplot(n_rows, n_cols, i_plot);
    imagesc(J_eff_array(:,:,i_plot));
    colormap(redwhiteblue_colormap(256));
    clim([-5, 5]);  % Hard-coded clim for J_eff
    axis square;
    set(gca, 'XTick', [], 'YTick', []);
    box off;
    set(gca, 'Color', 'none');
    set(gca, 'XColor', 'white', 'YColor', 'white', 'Layer', 'bottom');
end
end

function plot_W_colorbar_fig()
%PLOT_W_COLORBAR_FIG Create separate colorbar figure for W

figure('Position', [100, 346, 285, 154], 'Color', 'white');
ax = axes('Position', [0.3, 0.1, 0.3, 0.8]);
colormap(redwhiteblue_colormap(256));
cb = colorbar('Location', 'east');
clim([-0.5, 0.5]);
set(gca, 'Visible', 'off', 'Color', 'none');
set(cb, 'AxisLocation', 'out', 'Ticks', [-0.5, 0.5]);
ylabel(cb, 'W', 'Interpreter', 'tex', 'FontSize', 14);
end

function plot_J_eff_colorbar_fig()
%PLOT_J_EFF_COLORBAR_FIG Create separate colorbar figure for J_eff

figure('Position', [100, 500, 285, 154], 'Color', 'white');
ax = axes('Position', [0.3, 0.1, 0.3, 0.8]);
colormap(redwhiteblue_colormap(256));
cb = colorbar('Location', 'east');
clim([-5, 5]);
set(gca, 'Visible', 'off', 'Color', 'none');
set(cb, 'AxisLocation', 'out', 'Ticks', [-5, 5]);
ylabel(cb, 'J_{eff}', 'Interpreter', 'tex', 'FontSize', 14);
end
