% Simple_network_with_dual_adaptation.m
%
% A basic SRNN simulation demonstrating dual adaptation (SFA + STD)
% using default SRNNModel properties. Computes FTLE, local LLE, and
% plots full time series.

%% Setup paths
setup_paths();

%% Create and configure model with dual adaptation
model = SRNNModel();

% Enable dual adaptation: SFA (spike-frequency adaptation) + STD (short-term depression)
model.n_a_E = 3;   % 3 adaptation timescales for excitatory neurons (SFA)
model.n_b_E = 1;   % 1 STD timescale for excitatory neurons (STD)

% Rectify stimulus (positive only) and stimulate E neurons only
model.input_config.positive_only = true;
model.input_config.step_density_I = 0;  % No stimulus to I neurons

% Use Benettin's method for Lyapunov computation (computes FTLE and local LLE)
model.lya_method = 'benettin';

%% Build and run the model
model.build();
model.run();

%% Display Lyapunov results
fprintf('\n=== Lyapunov Exponent Results ===\n');
fprintf('Largest Lyapunov Exponent (LLE): %.4f\n', model.lya_results.LLE);
fprintf('Final Finite-Time LE (FTLE): %.4f\n', model.lya_results.finite_lya(end));
fprintf('Mean Local LLE: %.4f\n', mean(model.lya_results.local_lya));

%% Plot time series with Lyapunov exponents
model.plot();
