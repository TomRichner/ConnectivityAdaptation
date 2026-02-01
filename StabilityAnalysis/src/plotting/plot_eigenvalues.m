function ax = plot_eigenvalues(eigenvalues, ax, time_value, x_lim, y_lim, circle_params)
% plot_eigenvalues - Plot eigenvalue distribution on complex plane
%
% Syntax:
%   ax = plot_eigenvalues(eigenvalues, ax, time_value)
%   ax = plot_eigenvalues(eigenvalues, ax, time_value, x_lim, y_lim)
%   ax = plot_eigenvalues(eigenvalues, ax, time_value, x_lim, y_lim, circle_params)
%
% Description:
%   Plots eigenvalue distribution on the complex plane with polished styling
%   including LaTeX formatted labels and manual reference axes. Based on the
%   style from RMT_figure.m for a professional appearance.
%
% Inputs:
%   eigenvalues - Complex vector of eigenvalues to plot
%   ax          - Axes handle to plot on (e.g., from subplot)
%   time_value  - Time value to display in title (in seconds)
%   x_lim       - (Optional) [xmin xmax] limits for x-axis
%   y_lim       - (Optional) [ymin ymax] limits for y-axis
%   circle_params - (Optional) struct with fields 'center' and 'radius'
%
% Outputs:
%   ax - Axes handle (returned for convenience)
%
% Example:
%   figure;
%   ax = subplot(2, 2, 1);
%   evals = eig(randn(100));
%   ax = plot_eigenvalues(evals, ax, 5.0);
%
% See also: plot_lyapunov, plot_SRNN_tseries

% Handle optional arguments
if nargin < 6
    circle_params = [];
end
if nargin < 5
    y_lim = [];
end
if nargin < 4
    x_lim = [];
end

% Make the specified axes current
axes(ax);

% Identify outliers if circle parameters are provided
is_outlier = false(size(eigenvalues));
if ~isempty(circle_params) && isfield(circle_params, 'center') && isfield(circle_params, 'radius')
    dists = abs(eigenvalues - circle_params.center);
    is_outlier = dists > circle_params.radius;
end

% Scatter plot of eigenvalues
hold on;
% Plot non-outliers (standard style: unfilled black circles)
if any(~is_outlier)
    scatter(real(eigenvalues(~is_outlier)), imag(eigenvalues(~is_outlier)), 36, ...
        'MarkerEdgeColor', [0 0 0], 'MarkerFaceColor', 'none', 'LineWidth', 0.5);
end

% Plot outliers (new style: black x)
if any(is_outlier)
    scatter(real(eigenvalues(is_outlier)), imag(eigenvalues(is_outlier)), 36, ...
        'MarkerEdgeColor', [0 0 0], 'Marker', 'x', 'LineWidth', 1.0);
end

% Draw theoretical circle if provided
if ~isempty(circle_params) && isfield(circle_params, 'center') && isfield(circle_params, 'radius')
    theta = linspace(0, 2*pi, 100);
    x_circ = real(circle_params.center) + circle_params.radius * cos(theta);
    y_circ = imag(circle_params.center) + circle_params.radius * sin(theta);
    plot(x_circ, y_circ, 'k--', 'LineWidth', 1.0);
end

% Get axis limits (use auto-scaled if not provided)
if isempty(x_lim)
    x_lim = xlim;
end

% Ensure right xlim always includes 0
if x_lim(2) < 0
    x_lim(2) = 0.05;
end

if isempty(y_lim)
    y_lim = ylim;
end

% Turn axis off for cleaner appearance
axis off;

% Add manual reference lines at Re=0 and Im=0
hold on;
h_x = plot(x_lim, [0, 0], 'k', 'LineWidth', 1.25);
h_y = plot([0, 0], y_lim, 'k', 'LineWidth', 1.25);

% Move reference lines to bottom layer
uistack([h_x, h_y], 'bottom');

% Add LaTeX formatted axis labels
% Position Re label near right edge of x-axis
text(1.02*x_lim(2), 0, ' Re($\lambda$)', 'Interpreter', 'latex', ...
    'VerticalAlignment', 'middle');

% Position Im label near top of y-axis
text(0, y_lim(2), 'Im($\lambda$)', 'Interpreter', 'latex', ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

% Restore axis limits (in case they changed)
xlim(x_lim);
ylim(y_lim);

hold off;

% Set equal aspect ratio for proper circular representation
axis equal;
end

