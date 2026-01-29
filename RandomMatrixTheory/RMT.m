classdef RMT < handle
    % RMT - Random Matrix Theory class following Harris et al. (2023)
    % Variable names match the paper's notation for equations 15-18, 24-25, 30-31

    properties
        N               % System size
        alpha           % Sparsity/connection probability (0 < alpha <= 1)
        f               % Fraction of excitatory neurons

        % Normalized population statistics (tilde notation from Harris 2023)
        % These are the pre-sparsity parameters: mu_tilde = mu/sqrt(N), sigma_tilde = sigma/sqrt(N)
        mu_tilde_e      % Normalized mean of excitatory population
        mu_tilde_i      % Normalized mean of inhibitory population
        sigma_tilde_e   % Normalized std dev of excitatory population
        sigma_tilde_i   % Normalized std dev of inhibitory population

        % Internal matrices
        A               % Base random matrix (Gaussian, mean 0, var 1)
        S               % Sparsity mask (logical)

        % Control flags
        zrs_mode        % 'none', 'ZRS', 'SZRS', 'Partial_SZRS'
        shift           % Scalar shift for eigenvalues (diagonal shift)

        % Visualization
        description
        outlier_threshold  % Multiplier for R to determine outlier eigenvalues (default 1.03)
    end

    properties (Dependent)
        % Population indices (computed from f and N)
        E               % Logical index for Excitatory neurons
        I               % Logical index for Inhibitory neurons

        % Low-rank structure M = u * v' (Eq 12)
        u               % Left vector: ones(N,1)
        v               % Right vector: [mu_tilde_e repeated Nf times, mu_tilde_i repeated N(1-f) times]

        % Variance structure (Eq 11)
        D               % Diagonal variance matrix: diag(sigma_tilde_e repeated Nf, sigma_tilde_i repeated N(1-f))

        % Weight/Jacobian matrix
        W               % Jacobian matrix (computed on access)

        % Sparse statistics (Eq 15, 16)
        mu_se           % Sparse excitatory mean: alpha * mu_tilde_e
        mu_si           % Sparse inhibitory mean: alpha * mu_tilde_i
        sigma_se_sq     % Sparse excitatory variance (Eq 16)
        sigma_si_sq     % Sparse inhibitory variance (Eq 16)

        % Theoretical predictions (Eq 17, 18)
        lambda_O        % Outlier eigenvalue
        R               % Spectral radius
    end

    properties (Access = private)
        eigenvalues_cache   % Cached eigenvalue computation
        eigenvalues_valid   % Flag indicating if cache is valid
    end

    methods
        function obj = RMT(N)
            % RMT Constructor
            obj.N = N;

            % Defaults
            obj.alpha = 1.0;
            obj.f = 0.5;
            obj.mu_tilde_e = 0;
            obj.mu_tilde_i = 0;
            obj.sigma_tilde_e = 1/sqrt(N);  % Default: unit variance when scaled by sqrt(N)
            obj.sigma_tilde_i = 1/sqrt(N);

            obj.zrs_mode = 'none';
            obj.shift = 0;
            obj.description = '';
            obj.outlier_threshold = 1.04;

            % Initialize random matrices
            obj.A = randn(N, N);  % Mean 0, Var 1
            obj.update_sparsity();

            % Initialize eigenvalue cache
            obj.eigenvalues_cache = [];
            obj.eigenvalues_valid = false;
        end

        %% Dependent Property Getters
        function val = get.E(obj)
            val = false(obj.N, 1);
            val(1:round(obj.f * obj.N)) = true;
        end

        function val = get.I(obj)
            val = ~obj.E;
        end

        function val = get.u(obj)
            val = ones(obj.N, 1);
        end

        function val = get.v(obj)
            val = zeros(obj.N, 1);
            E_idx = obj.E;
            val(E_idx) = obj.mu_tilde_e;
            val(~E_idx) = obj.mu_tilde_i;
        end

        function val = get.D(obj)
            % Eq 11: D = diag(sigma_tilde_e repeated Nf times, sigma_tilde_i repeated N(1-f) times)
            D_vec = zeros(obj.N, 1);
            E_idx = obj.E;
            D_vec(E_idx) = obj.sigma_tilde_e;
            D_vec(~E_idx) = obj.sigma_tilde_i;
            val = diag(D_vec);
        end

        function val = get.W(obj)
            % Construct weight matrix W based on Harris 2023 equations

            % Get diagonal variance matrix D (Eq 11) and low-rank structure M (Eq 12)
            D = obj.D;
            M = obj.u * obj.v';

            switch obj.zrs_mode
                case 'none'
                    % Standard construction: W = S .* (A*D + M)  (Eq 6)
                    W_dense = (obj.A * D) + M;
                    val = obj.S .* W_dense;

                case 'ZRS'
                    % Dense ZRS using Projection Operator P (Eq 24, 25)
                    % Eq 24: P = I_N - (u*u')/N
                    % Eq 25: W = A*D*P + u*v'

                    if obj.alpha < 1
                        warning('RMT:SparsityWarning', 'Using ''ZRS'' (projection) with sparse matrix. This will destroy sparsity. Consider ''SZRS''.');
                    end

                    % Eq 24: Projection operator
                    P = eye(obj.N) - (obj.u * obj.u') / obj.N;

                    % Eq 25: W = A*D*P + M
                    val = (obj.A * D * P) + M;

                    if obj.alpha < 1
                        val = obj.S .* val;
                    end

                case 'SZRS'
                    % Sparse Zero Row Sum (Eq 30, 31)
                    % Eq 30: W = S .* (A*D + u*v') - B
                    % Eq 31: W_bar_i = sum_j W_ij / sum_j S_ij

                    % Base sparse matrix
                    W_base = obj.S .* ((obj.A * D) + M);

                    % Eq 31: Row averages of non-zero elements
                    row_sums = sum(W_base, 2);
                    row_counts = sum(obj.S, 2);
                    row_counts(row_counts == 0) = 1;  % Avoid division by zero
                    W_bar_i = row_sums ./ row_counts;

                    % Correction matrix B: B_ij = S_ij * W_bar_i
                    B = obj.S .* W_bar_i;

                    % Eq 30: Final matrix
                    val = W_base - B;

                case 'Partial_SZRS'
                    % Partial SZRS (Eq 32)
                    % Apply correction ONLY to random component J = S .* (A*D)
                    % Keep M component (S .* M) intact to preserve imbalance

                    % Random component
                    J_base = obj.S .* (obj.A * D);

                    % Mean structure component
                    M_base = obj.S .* M;

                    % Eq 32: Row averages of random component J only
                    J_row_sums = sum(J_base, 2);
                    row_counts = sum(obj.S, 2);
                    row_counts(row_counts == 0) = 1;
                    J_bar_i = J_row_sums ./ row_counts;

                    % Partial correction B
                    B_partial = obj.S .* J_bar_i;

                    % W = (J_base - B_partial) + M_base
                    val = (J_base - B_partial) + M_base;
            end

            % Apply diagonal shift
            val = val + obj.shift * eye(obj.N);
        end

        function val = get.mu_se(obj)
            % Eq 15: mu_se = alpha * mu_tilde_e
            val = obj.alpha * obj.mu_tilde_e;
        end

        function val = get.mu_si(obj)
            % Eq 15: mu_si = alpha * mu_tilde_i
            val = obj.alpha * obj.mu_tilde_i;
        end

        function val = get.sigma_se_sq(obj)
            % Eq 16: sigma_se^2 = alpha*(1-alpha)*mu_tilde_e^2 + alpha*sigma_tilde_e^2
            val = obj.alpha * (1 - obj.alpha) * obj.mu_tilde_e^2 + obj.alpha * obj.sigma_tilde_e^2;
        end

        function val = get.sigma_si_sq(obj)
            % Eq 16: sigma_si^2 = alpha*(1-alpha)*mu_tilde_i^2 + alpha*sigma_tilde_i^2
            val = obj.alpha * (1 - obj.alpha) * obj.mu_tilde_i^2 + obj.alpha * obj.sigma_tilde_i^2;
        end

        function val = get.lambda_O(obj)
            % Eq 17: lambda_O = N * [f * mu_se + (1-f) * mu_si]
            val = obj.N * (obj.f * obj.mu_se + (1 - obj.f) * obj.mu_si);
        end

        function val = get.R(obj)
            % Eq 18: R = sqrt(N * [f * sigma_se^2 + (1-f) * sigma_si^2])
            val = sqrt(obj.N * (obj.f * obj.sigma_se_sq + (1 - obj.f) * obj.sigma_si_sq));
        end

        %% Property Setters with cache invalidation
        function set.alpha(obj, val)
            obj.alpha = val;
            if ~isempty(obj.A)
                obj.update_sparsity();
            end
            obj.invalidate_eigenvalues();
        end

        function set.f(obj, val)
            obj.f = val;
            obj.invalidate_eigenvalues();
        end

        function set.mu_tilde_e(obj, val)
            obj.mu_tilde_e = val;
            obj.invalidate_eigenvalues();
        end

        function set.mu_tilde_i(obj, val)
            obj.mu_tilde_i = val;
            obj.invalidate_eigenvalues();
        end

        function set.sigma_tilde_e(obj, val)
            obj.sigma_tilde_e = val;
            obj.invalidate_eigenvalues();
        end

        function set.sigma_tilde_i(obj, val)
            obj.sigma_tilde_i = val;
            obj.invalidate_eigenvalues();
        end

        function set.zrs_mode(obj, val)
            obj.zrs_mode = val;
            obj.invalidate_eigenvalues();
        end

        function set.shift(obj, val)
            obj.shift = val;
            obj.invalidate_eigenvalues();
        end

        %% Parameter Setters
        function set_params(obj, mu_tilde_e, mu_tilde_i, sigma_tilde_e, sigma_tilde_i, f, alpha)
            % Set all parameters in Harris 2023 notation
            % Arguments: mu_tilde_e, mu_tilde_i, sigma_tilde_e, sigma_tilde_i, f, alpha
            if nargin > 1, obj.mu_tilde_e = mu_tilde_e; end
            if nargin > 2, obj.mu_tilde_i = mu_tilde_i; end
            if nargin > 3, obj.sigma_tilde_e = sigma_tilde_e; end
            if nargin > 4, obj.sigma_tilde_i = sigma_tilde_i; end
            if nargin > 5, obj.f = f; end
            if nargin > 6, obj.alpha = alpha; end
        end

        function set_alpha(obj, alpha)
            % Set alpha (sparsity) independently
            obj.alpha = alpha;
        end

        function set_zrs_mode(obj, mode)
            % Set the zero row-sum mode
            valid_modes = {'none', 'ZRS', 'SZRS', 'Partial_SZRS'};
            if ~ismember(mode, valid_modes)
                error('Invalid ZRS mode. Valid choices: %s', strjoin(valid_modes, ', '));
            end
            obj.zrs_mode = mode;
        end

        function sigma_tilde_i = compute_sigma_tilde_i_for_target_variance(obj, target_variance)
            % Compute sigma_tilde_i to achieve a target expected variance Var(W)

            % Check that alpha = 1 (dense case only)
            if obj.alpha < 1
                error('RMT:SparseCaseNotSupported', ...
                    'compute_sigma_tilde_i_for_target_variance only supports dense matrices (alpha=1). For alpha<1, a more complex solver is needed.');
            end

            % For dense case (alpha=1), sigma_se^2 = sigma_tilde_e^2
            sigma_se_sq = obj.sigma_tilde_e^2;

            sigma_si_sq = (target_variance - obj.f * sigma_se_sq) / (1 - obj.f);

            % Check that the result is valid (non-negative)
            if sigma_si_sq < 0
                error('RMT:InvalidTargetVariance', ...
                    'Target variance %.4f is too small. Minimum achievable is %.4f (when sigma_tilde_i=0).', ...
                    target_variance, obj.f * sigma_se_sq);
            end

            sigma_tilde_i = sqrt(sigma_si_sq);
        end

        %% Internal Updates
        function update_sparsity(obj)
            obj.S = rand(obj.N, obj.N) < obj.alpha;
            obj.invalidate_eigenvalues();
        end

        %% Display and Diagnostics
        function display_parameters(obj)
            % Display measured statistics from W and compare to theoretical predictions
            W_mat = obj.W;

            % Remove diagonal for statistics since they may contain shift
            W_no_diag = W_mat;
            W_no_diag(1:obj.N+1:end) = NaN;

            % Extract E and I columns
            E_idx = obj.E;
            W_E = W_no_diag(:, E_idx);
            W_I = W_no_diag(:, ~E_idx);

            % For sparse matrices, only consider non-zero entries
            W_E_vals = W_E(~isnan(W_E) & (W_E ~= 0));
            W_I_vals = W_I(~isnan(W_I) & (W_I ~= 0));

            % Measured statistics (of non-zero entries)
            measured_mu_E = mean(W_E_vals);
            measured_mu_I = mean(W_I_vals);
            measured_sigma_E = std(W_E_vals, 1);
            measured_sigma_I = std(W_I_vals, 1);

            % Theoretical predictions (use dependent properties directly)
            mu_se = obj.mu_se;
            mu_si = obj.mu_si;
            sigma_se_sq = obj.sigma_se_sq;
            sigma_si_sq = obj.sigma_si_sq;
            lambda_O = obj.lambda_O;
            R = obj.R;

            fprintf('\n========== RMT Parameter Summary ==========\n');
            if ~isempty(obj.description)
                fprintf('Description:          %s\n', obj.description);
            end
            fprintf('Mode:                 %s\n', obj.zrs_mode);
            fprintf('N:                    %d\n', obj.N);
            fprintf('alpha:                %.4f\n', obj.alpha);
            fprintf('f:                    %.4f\n', obj.f);
            fprintf('\n--- Harris 2023 Notation ---\n');
            fprintf('                      Set Value    Sparse Eff.  Measured(NZ)\n');
            fprintf('--------------------------------------------------------------\n');
            fprintf('mu_tilde_e            %10.4f   mu_se=%.4f   %.4f\n', obj.mu_tilde_e, mu_se, measured_mu_E);
            fprintf('mu_tilde_i            %10.4f   mu_si=%.4f   %.4f\n', obj.mu_tilde_i, mu_si, measured_mu_I);
            fprintf('sigma_tilde_e         %10.4f   sigma_se=%.4f  %.4f\n', obj.sigma_tilde_e, sqrt(sigma_se_sq), measured_sigma_E);
            fprintf('sigma_tilde_i         %10.4f   sigma_si=%.4f  %.4f\n', obj.sigma_tilde_i, sqrt(sigma_si_sq), measured_sigma_I);
            fprintf('\n--- Theoretical Predictions (Eq 17, 18) ---\n');
            fprintf('lambda_O (outlier):   %.4f\n', lambda_O);
            fprintf('R (radius):           %.4f\n', R);
            fprintf('==============================================\n\n');
        end

        %% Eigenvalue Computation (with caching)
        function eigs = get_eigenvalues(obj)
            % Get eigenvalues, computing only if cache is invalid
            if ~obj.eigenvalues_valid || isempty(obj.eigenvalues_cache)
                obj.eigenvalues_cache = eig(obj.W);
                obj.eigenvalues_valid = true;
            end
            eigs = obj.eigenvalues_cache;
        end

        function compute_eigenvalues(obj)
            % Force recomputation and cache update
            obj.eigenvalues_cache = eig(obj.W);
            obj.eigenvalues_valid = true;
        end

        function eigs = eigenvalues(obj)
            % Property-like access for eigenvalues
            eigs = obj.get_eigenvalues();
        end

        %% Plotting
        function plot_spectrum(obj, ax)
            if nargin < 2
                figure; ax = gca;
            end

            eigs = obj.get_eigenvalues();

            % Get theoretical radius and center
            R = obj.R;
            xc = obj.shift;
            yc = 0;

            % Compute distances from center for all eigenvalues
            distances = abs(eigs - xc - 1i*yc);

            % Plot interior eigenvalues (within R) as black circles
            mSize = 4;
            interior_mask = distances <= R;
            interior_eigs = eigs(interior_mask);
            plot(ax, real(interior_eigs), imag(interior_eigs), 'ko', 'MarkerSize', mSize, 'MarkerFaceColor', 'none', 'LineWidth', 0.5);
            hold(ax, 'on');

            % Plot theoretical radius (Eq 18)
            theta = linspace(0, 2*pi, 100);
            plot(ax, xc + R*cos(theta), yc + R*sin(theta), 'k-', 'LineWidth', 2);

            % Plot near outlier eigenvalues (between R and outlier_threshold*R) as black Xs
            near_outlier_mask = (distances > R) & (distances <= obj.outlier_threshold * R);
            near_outlier_eigs = eigs(near_outlier_mask);
            if ~isempty(near_outlier_eigs)
                plot(ax, real(near_outlier_eigs), imag(near_outlier_eigs), 'kx', 'MarkerSize', mSize, 'LineWidth', 0.5);
            end

            % Plot far outlier eigenvalues (beyond outlier_threshold*R) as green filled circles
            far_outlier_mask = distances > obj.outlier_threshold * R;
            far_outlier_eigs = eigs(far_outlier_mask);
            if ~isempty(far_outlier_eigs)
                plot(ax, real(far_outlier_eigs), imag(far_outlier_eigs), 'o', 'MarkerSize', mSize, 'MarkerFaceColor', [0 .7 0], 'MarkerEdgeColor', [0 .7 0]);
            end

            xlabel(ax, 'Re(\lambda)');
            ylabel(ax, 'Im(\lambda)');
            grid(ax, 'on');
            axis(ax, 'equal');
            hold(ax, 'off');
        end

        %% Deep Copy
        function new_obj = copy(obj)
            % Create new object with same N
            new_obj = RMT(obj.N);

            % Copy stored (non-dependent) properties
            new_obj.alpha = obj.alpha;
            new_obj.f = obj.f;
            new_obj.mu_tilde_e = obj.mu_tilde_e;
            new_obj.mu_tilde_i = obj.mu_tilde_i;
            new_obj.sigma_tilde_e = obj.sigma_tilde_e;
            new_obj.sigma_tilde_i = obj.sigma_tilde_i;
            new_obj.A = obj.A;
            new_obj.S = obj.S;
            new_obj.zrs_mode = obj.zrs_mode;
            new_obj.shift = obj.shift;
            new_obj.description = obj.description;
            new_obj.outlier_threshold = obj.outlier_threshold;
            new_obj.eigenvalues_cache = obj.eigenvalues_cache;
            new_obj.eigenvalues_valid = obj.eigenvalues_valid;
        end
    end

    methods (Access = private)
        function invalidate_eigenvalues(obj)
            obj.eigenvalues_valid = false;
        end
    end
end
