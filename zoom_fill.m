function [h, fill_ax] = zoom_fill(ax_top, ax_bottom, top_range, bottom_range, varargin)
%ZOOM_FILL  Draw a connecting zoom polygon between two axes
%
%   Usage:
%       [h, fill_ax] = zoom_fill(ax_top, ax_bottom, top_range, bottom_range, ...)
%
%   Inputs:
%       ax_top       : axes handle - top axes -- required
%       ax_bottom    : axes handle - bottom axes -- required
%       top_range    : 1x2 double - x-range on top axes (default: ax_top.XLim)
%       bottom_range : 1x2 double - x-range on bottom axes (default: ax_bottom.XLim)
%
%   Name-Value Pairs:
%       Any name-value pair accepted by the fill object is forwarded via SET.
%
%   Outputs:
%       h       : handle to the fill object
%       fill_ax : handle to the overlay axes
%
%   Notes:
%       The overlay axes auto-update when either source axes' XLim changes
%       (scroll, zoom, pan, programmatic).
%
%   Example:
%       ax_top    = subplot(211);
%       ax_bottom = subplot(212);
%       imagesc(ax_top,    linspace(50,100),   linspace(0,100),  peaks(500));
%       imagesc(ax_bottom, linspace(3000,4100),linspace(-53,84), membrane(10,499));
%       [h, fill_ax] = zoom_fill(ax_top, ax_bottom, [75 85], [], ...
%           'FaceColor','cyan','EdgeColor','blue');
%
%   See also: fill, axes, addlistener
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

if nargin == 0
    ax_top = subplot(211);
    ax_bottom = subplot(212);

    imagesc(ax_top, linspace(50,100), linspace(0,100), peaks(500));
    imagesc(ax_bottom, linspace(3000,4100), linspace(-53,84), membrane(10,499));

    top_range    = [75 85];  % example top range
    bottom_range = [];        % default bottom range

    [h, fill_ax] = zoom_fill(ax_top, ax_bottom, top_range, bottom_range, ...
        'FaceColor','cyan','EdgeColor','blue');
    return;
end

% Defaults
if nargin < 3 || isempty(top_range)
    top_range = ax_top.XLim;
end
if nargin < 4 || isempty(bottom_range)
    bottom_range = ax_bottom.XLim;
end

% Validate ranges
assert(all(top_range >= ax_top.XLim(1) & top_range <= ax_top.XLim(2)), ...
    'Top range exceeds axis limits');
assert(all(bottom_range >= ax_bottom.XLim(1) & bottom_range <= ax_bottom.XLim(2)), ...
    'Bottom range exceeds axis limits');

% Get normalized positions
set(gcf,'Units','normalized');
pos_top    = get(ax_top, 'Position');
pos_bottom = get(ax_bottom, 'Position');

left_edge   = min(pos_top(1), pos_bottom(1));
right_edge  = max(pos_top(1)+pos_top(3), pos_bottom(1)+pos_bottom(3));
bottom_edge = min(pos_top(2)+pos_top(4), pos_bottom(2)+pos_bottom(4));
top_edge    = max(pos_top(2), pos_bottom(2));

total_width  = right_edge - left_edge;
total_height = top_edge  - bottom_edge;

% Create overlay axes
fill_ax = axes('Position',[left_edge, bottom_edge, total_width, total_height]);
fill_ax.Color = 'none';
fill_ax.XLim  = [0 1];
fill_ax.YLim  = [0 1];

% Normalized coordinates
top_prop    = (top_range - ax_top.XLim(1)) / diff(ax_top.XLim);
bottom_prop = (bottom_range - ax_bottom.XLim(1)) / diff(ax_bottom.XLim);

x_fill = [top_prop, fliplr(bottom_prop)];
y_fill = [1 1 0 0];

% Make fill_ax current
axes(fill_ax);

% Always create fill with default face color and no edge
h = fill(x_fill, y_fill, [0.7 0.7 0.7], 'EdgeColor','none');

% Apply varargin options if provided
if ~isempty(varargin)
    set(h, varargin{:});
end

axis(fill_ax,'off');
uistack(fill_ax,'bottom');

% --- Update function
function update_fill(~,~)
    top_vals = top_range; bottom_vals = bottom_range;
    if isempty(top_vals), top_vals = ax_top.XLim; end
    if isempty(bottom_vals), bottom_vals = ax_bottom.XLim; end
    top_prop = (top_vals - ax_top.XLim(1)) / diff(ax_top.XLim);
    bottom_prop = (bottom_vals - ax_bottom.XLim(1)) / diff(ax_bottom.XLim);
    h.XData = [top_prop, fliplr(bottom_prop)];
    h.YData = [1 1 0 0];
end

% --- Listeners for any XLim change (scroll, zoom, pan, programmatic)
addlistener(ax_top,'XLim','PostSet',@update_fill);
addlistener(ax_bottom,'XLim','PostSet',@update_fill);

% --- Initial update
update_fill();
end
