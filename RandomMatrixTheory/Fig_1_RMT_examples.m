% Illustrative examples for RMT class based on Harris et al. 2023
% Equations from Harris, I. D., Meffin, H., Burkitt, A. N. & Peterson, A. D. H. Effect of sparsity on network stability in random neural networks obeying Dale's law. Phys. Rev. Res. 5, 043132 (2023).
% Code implementation by Thomas J. Richner for a small perspectives manuscript which briefly reviews random matrix theory including the excellent work by Harris et al.

% clear; close all; clc;  % Commented out for master script compatibility

save_figs = false; % saves fig, svg, png, jpeg2000

rng(100) % reproducibility

N = 600; % number of neurons

G = struct(); % matlab structure to contain examples

g = 0; % example index

%% (a) Dense random matrix, unbalanced with global outlier
g = g + 1;
G(g).rmt = RMT(N);
E_W = +0.05/sqrt(N); % Expected mean weight is added to both E and I weight distributions, creates global outlier
% tilde notation indicates 1/sqrt(N) normalization (Harris et al. 2023)
G(g).rmt.mu_tilde_e = 0 + E_W;      % normalized mean of excitatory weights
G(g).rmt.mu_tilde_i = 0 + E_W;      % normalized mean of inhibitory weights
G(g).rmt.sigma_tilde_e = 1/sqrt(N); % normalized std dev of excitatory weights
G(g).rmt.sigma_tilde_i = 1/sqrt(N); % normalized std dev of inhibitory weights
G(g).rmt.f = 1;                     % fraction of excitatory neurons = 100% excitatory
G(g).rmt.alpha = 1.0;               % connection probability (1 = fully connected)
G(g).rmt.set_zrs_mode('none');      % no zero-row-sum normalization needed for dense i.i.d distributions.
G(g).rmt.description = 'Dense random matrix unbalanced, no ZRS';
G(g).rmt.display_parameters(); % display set, theoretical, and measured stats

%% (b) Dense balanced shifted
g = g + 1;
G(g).rmt = G(g-1).rmt.copy();       % copy from the previous example
G(g).rmt.mu_tilde_e = 0;            % remove imbalance and outlier by setting means to zero
G(g).rmt.mu_tilde_i = 0;
R = G(g).rmt.R;                     % computes theoretical spectral radius
G(g).rmt.shift = -R;                % Shift all eigenvalues left by subtracting R*eye(N) along the main diagonal
G(g).rmt.description = 'Dense shifted';
G(g).rmt.display_parameters();

%% (c) Dense balanced Dale's law
g = g + 1;
G(g).rmt = G(g-1).rmt.copy();
G(g).rmt.mu_tilde_e = 1/sqrt(N);    % positive excitatory mean (Dale's law)
G(g).rmt.mu_tilde_i = -1/sqrt(N);   % negative inhibitory mean (Dale's law)
G(g).rmt.sigma_tilde_e = 1/sqrt(N); % excitatory std dev
G(g).rmt.sigma_tilde_i = 1/sqrt(N); % inhibitory std dev
G(g).rmt.f = 0.5;                   % 50% excitatory, 50% inhibitory
G(g).rmt.description = 'Dense balanced Dales law';
G(g).rmt.display_parameters();

%% (d) Dense balanced Dales ZRS
g = g + 1;
G(g).rmt = G(g-1).rmt.copy();
G(g).rmt.set_zrs_mode('ZRS'); % applys zero row sum condition see Rajan and Abbott 2006
G(g).rmt.description = 'Dense Dales ZRS';
G(g).rmt.display_parameters();

%% (e) Dense Unbalanced Dales different sigmas ZRS still enabled
g = g + 1;
G(g).rmt = G(g-1).rmt.copy();
G(g).rmt.sigma_tilde_e = 0.35/sqrt(N); % Set a different sigma_tilde_e, then compute sigma_tilde_i to maintain target variance
target_variance = 1/N;  % Same total variance as before
G(g).rmt.sigma_tilde_i = G(g).rmt.compute_sigma_tilde_i_for_target_variance(target_variance); % From Harris 2023 Eq 14: Var(W) = f*σ_se² + (1-f)*σ_si², solved for σ_si². For dense (α=1), Eq 16 simplifies: σ_sk² = σ̃_k²
G(g).rmt.description = 'Dense Dales different sigmas ZRS';
G(g).rmt.display_parameters();

%% (f) Sparse Unbalanced with Partial SZRS (Eq 32)
g = g + 1;
G(g).rmt = G(g-1).rmt.copy();
G(g).rmt.set_alpha(0.5); % make the matrix 50% sparse
G(g).rmt.set_zrs_mode('Partial_SZRS'); % apply Partial SZRS.  Row zero sum is applied to S o AD, but not S o uv^T
G(g).rmt.description = 'Sparse Unbalanced Dales Partial SZRS';
G(g).rmt.display_parameters();

%% Compute eigenvalues and make plots
f1 = figure(1);
set(f1, 'Position', [100   300   760   600], 'Color', 'white'); % note: Position isn't really obeyed when using daspect(ax(i), [1 1 1])
t = tiledlayout(2, ceil(length(G)/2), 'TileSpacing', 'tight', 'Padding', 'compact');

ax = gobjects(length(G), 1); % will hold on to graphics handles

for i = 1:length(G)
    % Compute eigenvalues
    G(i).rmt.compute_eigenvalues(); % compute the eigenvalues with eig()

    % Plot
    ax(i) = nexttile;
    G(i).rmt.plot_spectrum(ax(i)); % make a plot of the  eigenspectrum
end

%% reformat plots to have nice looking axes and similar scaling across examples
% Determine global scale centered on each plot's shift
max_radius_x = 0;
max_radius_y = 0;
max_R = 0;

for i = 1:length(G)
    axis(ax(i), 'normal');
    axis(ax(i), 'tight');
    current_xlim = xlim(ax(i));
    current_ylim = ylim(ax(i));
    center_x = G(i).rmt.shift;
    dist_x = max(abs(current_xlim - center_x));
    dist_y = max(abs(current_ylim));
    max_radius_x = max(max_radius_x, dist_x);
    max_radius_y = max(max_radius_y, dist_y);
    max_R = max(max_R, G(i).rmt.R);
end

% Apply common scale with margin
margin = 1.1;
common_radius_x = max_radius_x * margin;
common_radius_y = max_radius_y * margin;

for i = 1:length(G)
    center_x = G(i).rmt.shift;
    xlim(ax(i), [center_x - common_radius_x, center_x + common_radius_x]);
    ylim(ax(i), [-common_radius_y, common_radius_y]);
    daspect(ax(i), [1 1 1]);
end

% Format axes
for i = 1:length(G)
    axes(ax(i));
    x_lim = xlim;
    y_lim = ylim;
    y_lim_axis = min(0.75*y_lim,1.1*max_R);%y_lim)
    axis off;

    hold on;
    h_x = plot(x_lim, [0,0], 'k', 'LineWidth', 1.5);
    h_y = plot([0,0], y_lim_axis, 'k', 'LineWidth', 1.5);
    uistack([h_x, h_y], 'bottom');

    text(x_lim(2), 0, ' Re', 'Interpreter', 'latex', 'VerticalAlignment', 'middle', 'FontSize', 16);
    text(0, y_lim_axis(2), 'Im', 'Interpreter', 'latex', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', 'FontSize', 16);
    % text(x_lim(1), y_lim(1), G(i).rmt.description, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'FontWeight', 'normal', 'Rotation', 90);

    xlim(x_lim);
    ylim(y_lim);
    hold off;
end

% Add letters (a), (b), etc. to subplots
letters = arrayfun(@(c) sprintf('(%s)', c), 'a':'z', 'UniformOutput', false);
AddLetters2Plots(num2cell(ax), letters, 'FontSize', 18, 'FontWeight', 'normal', 'HShift', +0.01, 'VShift', +0.01);

drawnow;
set(f1, 'Position', [100   300   760   600]);

%% save figures

if save_figs
    save_some_figs_to_folder_2('RMT_figs', 'RMT_examples', [], {'fig', 'svg', 'png', 'jp2'});
end