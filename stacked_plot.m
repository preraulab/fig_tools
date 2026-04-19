function new_axes = stacked_plot(ax, data, x, varargin)
%STACKED_PLOT  Plot multi-channel data as vertically stacked subplots with scale bars and optional row merging
%
%   Usage:
%       new_axes = stacked_plot(ax, data)
%       new_axes = stacked_plot(ax, data, x)
%       new_axes = stacked_plot(ax, data, x, 'Name', Value, ...)
%
%   Inputs:
%       ax   : axes handle (default: gca)
%       data : RxC double - R channels, C samples -- required
%       x    : 1xC numeric or datetime - sample positions (default: 1:C)
%
%   Name-Value Pairs:
%       'ylabels' : cell or string array - subplot labels (default: auto from merge)
%       'skip'    : integer - plot every nth sample (default: 1)
%       'colors'  : Rx3 double - per-channel RGB (default: lines(R))
%       'xscale'  : numeric scalar or datetime - x-axis scale bar length (default: [])
%       'xlabel'  : char - x scale bar label (default: '')
%       'yscale'  : numeric vector - per-subplot y scale bar length (default: [])
%       'ylabel'  : cell or string array - y scale bar labels (default: {})
%       'merge'   : cell array - rows to merge per subplot (default: each row its own subplot)
%
%   Outputs:
%       new_axes : array of axes handles
%
%   Example:
%       data = randn(7, 100);
%       x = datetime(2025,12,22,0,0,0) + minutes(1)*(0:99);
%       merge = {[1 5], 2, 3, [4 7], 6};
%       new_axes = stacked_plot(gca, data, x, 'merge', merge, 'skip', 2);
%
%   See also: split_axis, scaleline
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

%************************************************************
%                   INPUT HANDLING
%************************************************************
if nargin < 1 || isempty(ax) || ~ishandle(ax) || ~strcmp(get(ax, 'type'), 'axes')
    ax = gca;
end

[r, c] = size(data);

if nargin < 3 || isempty(x)
    x = 1:c;
end
assert(numel(x) == c, 'Length of x must match number of data columns.');

% Parse name-value pairs
p = inputParser;
addParameter(p, 'ylabels', []);
addParameter(p, 'skip', 1, @(v) isnumeric(v) && v>=1 && mod(v,1)==0);
addParameter(p, 'colors', lines(r), @(v) isnumeric(v) && size(v,1)==r && size(v,2)==3);
addParameter(p, 'xscale', []);
addParameter(p, 'xlabel', '');
addParameter(p, 'yscale', []);
addParameter(p, 'ylabel', {});
addParameter(p, 'merge', {});
parse(p, varargin{:});

skip = p.Results.skip;
colors = p.Results.colors;
xscale = p.Results.xscale;
xlabel_str = p.Results.xlabel;
yscale = p.Results.yscale;
ylabel_lines_raw = p.Results.ylabel;
merge = p.Results.merge;

% Normalize ylabel lines
if isstring(ylabel_lines_raw)
    ylabel_lines = cellstr(ylabel_lines_raw);
elseif iscell(ylabel_lines_raw)
    ylabel_lines = ylabel_lines_raw;
else
    ylabel_lines = {}; % fallback if empty or not provided
end

%************************************************************
%               MERGE HANDLING (explicit)
%************************************************************
if isempty(merge)
    % Default: each row is its own subplot
    merge = num2cell(1:r);
else
    % Ensure each cell contains a row vector
    merge = cellfun(@(v) v(:)', merge, 'UniformOutput', false);
end

n_plots = numel(merge);

%************************************************************
%           DEFAULT YLABELS BASED ON MERGE
%************************************************************
if isempty(p.Results.ylabels)
    ylabels = cell(1, n_plots);
    for ii = 1:n_plots
        rows_str = sprintf('%d,', merge{ii});
        rows_str(end) = []; % remove trailing comma
        ylabels{ii} = ['Rows ' rows_str];
    end
else
    % normalize input (string array or cell)
    ylabels_raw = p.Results.ylabels;
    if isstring(ylabels_raw)
        ylabels = cellstr(ylabels_raw);
    elseif iscell(ylabels_raw)
        ylabels = ylabels_raw;
    else
        error('ylabels must be a string array or cell array of chars.');
    end
end

% Validate dependent inputs
if ~isempty(yscale)
    assert(numel(yscale) == n_plots, 'yscale must match number of merged subplots.');
end
if ~isempty(ylabel_lines)
    assert(numel(ylabel_lines) == n_plots, 'ylabel must match number of merged subplots.');
end

%************************************************************
%                   AXIS CREATION
%************************************************************
new_axes = split_axis(ax, ones(1, n_plots)/n_plots, 1);

%************************************************************
%                   PLOTTING
%************************************************************
x_plot = x(1:skip:end);

for ii = 1:n_plots
    ax_i = new_axes(ii);
    rows_to_plot = merge{ii};
    hold(ax_i, 'on');
    for r_idx = rows_to_plot
        plot(ax_i, x_plot, data(r_idx, 1:skip:end), 'Color', colors(r_idx,:));
    end
    hold(ax_i, 'off');
    
    % Set ylabel
    ax_i.YLabel.String = ylabels{ii};
    
    % Remove x-axis ticks for all but bottom plot
    if ii < n_plots
        ax_i.XTick = [];
        ax_i.XColor = 'none';
    end
    
    % Add y-scale line if provided
    if ~isempty(yscale)
        sl_label = '';
        if ~isempty(ylabel_lines)
            sl_label = ylabel_lines{ii};
        end
        scaleline(ax_i, yscale(ii), sl_label, 'y');
    end
end

%************************************************************
%                   X-SCALE LINE (datetime safe)
%************************************************************
if ~isempty(xscale)
    ax_bottom = new_axes(end);
    
    if isdatetime(x)
        if isnumeric(xscale)
            xscale_dt = x(end) + days(xscale);  % numeric interpreted as duration in days
        elseif isdatetime(xscale)
            xscale_dt = xscale;
        else
            error('xscale must be numeric or datetime when x is datetime.');
        end
        scaleline(ax_bottom, xscale_dt, xlabel_str, 'x');
    else
        scaleline(ax_bottom, xscale, xlabel_str, 'x');
    end
end

%************************************************************
%                   FINAL COSMETICS
%************************************************************
new_axes(end).XColor = 'k';
box(new_axes(end), 'off');

end