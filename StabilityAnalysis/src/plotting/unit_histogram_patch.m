function unit_histogram_patch(data, color_values, num_bins, sort_mode)
% UNIT_HISTOGRAM_PATCH Creates a stacked histogram where every element is a patch.
% Inputs:
%   data         : Vector of x-axis distribution
%   color_values : Vector of values to determine color
%   num_bins     : Number of bins (default 20)
%   sort_mode    : 'sorted' (gradient) or 'random' (default 'sorted')

if nargin < 3, num_bins = 20; end
if nargin < 4, sort_mode = 'sorted'; end

% Ensure input data are column vectors
data = data(:);
color_values = color_values(:);

% 1. Discretization
[counts, edges] = histcounts(data, num_bins);
bin_width = edges(2) - edges(1);
bin_indices = discretize(data, edges);

% 2. Sorting Logic
T = table(data, color_values, bin_indices);
T = T(~isnan(T.bin_indices), :); % Remove NaNs

if strcmpi(sort_mode, 'random')
    T.rnd = rand(height(T), 1);
    T = sortrows(T, {'bin_indices', 'rnd'});
else
    % Default: Gradient effect
    T = sortrows(T, {'bin_indices', 'color_values'});
end

% 3. Calculate Stack Heights
[~, ~, unique_idx] = unique(T.bin_indices);
group_counts = accumarray(unique_idx, 1);

T.y_pos = zeros(height(T), 1);
current_idx = 1;
for i = 1:length(group_counts)
    n = group_counts(i);
    T.y_pos(current_idx : current_idx + n - 1) = (0 : n - 1)';
    current_idx = current_idx + n;
end

% 4. Construct Geometry (ROBUST VERSION)
% Force x_lefts and y_bottoms to be ROW vectors (1xN)
x_lefts = edges(T.bin_indices);
x_lefts = x_lefts(:)';

y_bottoms = T.y_pos(:)';

% Create 4xN matrices
X_verts = [x_lefts; x_lefts + bin_width; x_lefts + bin_width; x_lefts];
Y_verts = [y_bottoms; y_bottoms; y_bottoms + 1; y_bottoms + 1];

% 5. Rendering
figure;

% CData must match the number of faces (N), so we force it to 1xN
c_data = T.color_values(:)';

patch(X_verts, Y_verts, c_data, ...
    'FaceColor', 'flat', ...
    'EdgeColor', 'none');

colormap(parula);
c = colorbar;
ylabel(c, 'Secondary Value');

xlabel('Data Value');
ylabel('Count');
title(['Unit Histogram (' sort_mode ' stack)']);

axis tight;
ylim([0, max(counts) * 1.05]);
box on;
end