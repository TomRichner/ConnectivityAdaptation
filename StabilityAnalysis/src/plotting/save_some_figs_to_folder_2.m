function [] = save_some_figs_to_folder_2(save_folder, save_name, fig_vec, fig_type)
% saves a selection of figures to a folder in a selection of formats
% by Thomas J. Richner
%
% Inputs:
%   save_folder - (required) path to folder for saving figures
%   save_name   - (required) base name for saved files
%   fig_vec     - (optional) vector of figure numbers to save; if empty or
%                 not provided, saves all open figures
%   fig_type    - (optional) cell array of formats {'fig','svg','png','jp2'};
%                 if empty or not provided, defaults to {'fig','svg','png'}

% Input validation
if nargin < 2
    error('save_some_figs_to_folder_2:missingInputs', ...
        'save_folder and save_name are required inputs.');
end

if nargin < 3 || isempty(fig_vec)
    figHandles = findobj('Type', 'figure');
    fig_vec = zeros(1, length(figHandles));
    for i_f = 1:length(figHandles)
        fig_vec(i_f) = figHandles(i_f).Number;
    end
end

if nargin < 4 || isempty(fig_type)
    fig_type = {'fig','svg','png'}; % default to fig, svg, and png
end

% Create output directory if needed
if not(exist(save_folder,'dir'))
    fprintf('Creating directory: %s\n', save_folder);
    mkdir(save_folder)
else
    fprintf('Saving to existing directory: %s\n', save_folder);
end

for i=fig_vec
    set(i,'PaperPositionMode','auto')
    if any(strcmpi(fig_type,'fig'))
        saveas(i, fullfile(save_folder, [save_name '_f_' num2str(i)]), 'fig');
    end
    if any(strcmpi(fig_type,'png'))
        exportgraphics(figure(i), fullfile(save_folder, [save_name '_f_' num2str(i) '.png']), 'Resolution', 300)
    end
    if any(strcmpi(fig_type,'svg'))
        set(figure(i), 'Renderer', 'painters');
        saveas(i, fullfile(save_folder, [save_name '_f_' num2str(i)]), 'svg');
    end
    if any(strcmpi(fig_type,'jp2'))
        % Export at 300 DPI via temp PNG, then convert to lossless JP2
        temp_file = [tempname '.png'];
        print(figure(i), temp_file, '-dpng', '-r300');
        img = imread(temp_file);
        delete(temp_file);
        imwrite(img, fullfile(save_folder, [save_name '_f_' num2str(i) '.jpg']), 'jp2', 'Mode', 'lossless');
    end
end