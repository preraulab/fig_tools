function [h_scaleline, h_scalelabel] = scaleline(varargin)
%SCALELINE  Add a scale bar (with label) to an x- or y-axis; scales with zoom
%
%   Usage:
%       [h_scaleline, h_scalelabel] = scaleline(ax, time)
%       [h_scaleline, h_scalelabel] = scaleline(ax, time, label)
%       [h_scaleline, h_scalelabel] = scaleline(ax, time, label, line_axis)
%       [h_scaleline, h_scalelabel] = scaleline(ax, time, label, line_axis, gap)
%
%   Inputs:
%       ax        : axes handle (default: gca)
%       time      : double - scale length in plot units -- required
%       label     : char - label text (default: '<time> units')
%       line_axis : 'x' or 'y' - which axis the bar attaches to (default: 'x')
%       gap       : double - gap between bar and axis in normalized units (default: 0.01)
%
%   Outputs:
%       h_scaleline  : annotation handle for the scale bar
%       h_scalelabel : annotation handle for the label textbox
%
%   See also: annotation, stacked_plot
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main

%************************************************************
%                   PARSE INPUTS
%************************************************************
if ishandle(varargin{1}) && strcmp(get(varargin{1}, 'type'), 'axes')
    ax = varargin{1};
    time = varargin{2};
    varargin = varargin(3:end);
else
    ax = gca;
    time = varargin{1};
    varargin = varargin(2:end);
end

% Set default parameters
params = { [num2str(time) ' units'], 'x', 0.01 };
params(1:length(varargin)) = varargin;
[tstring, line_axis, gap] = params{:};

% Get axis position
axpos = get(ax, 'Position');

%************************************************************
%                   X-SCALE LINE
%************************************************************
if strcmpi(line_axis, 'x')
    set(ax, 'XTickLabel', '');
    
    % Compute normalized width of the line
    line_width = time / diff(xlim(ax));
    
    % Set annotation line position
    line_position = [axpos(1), axpos(2) - gap, axpos(3) * line_width, 0];
    h_scaleline = annotation(get(ax, 'Parent'), 'line', 'Position', line_position, 'LineWidth', 3);
    
    % Set label position
    text_position = [axpos(1) + axpos(3)/2 * line_width, axpos(2) - 2*gap, 0, 0];
    h_scalelabel = annotation(get(ax, 'Parent'), 'textbox', ...
        'Position', text_position, 'String', tstring, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
        'FitBoxToText', 'on', 'EdgeColor', 'none', 'BackgroundColor', 'none');
    
    % Add listener for zoom/pan
    addlistener(handle(ax), findprop(handle(ax), 'XLim'), 'PostSet', ...
        @(~,~) xscale_line(ax, time, gap, h_scaleline, h_scalelabel));

%************************************************************
%                   Y-SCALE LINE
%************************************************************
else
    set(ax, 'YTickLabel', '');
    
    % Compute normalized height of the line
    ylims = ylim(ax);
    line_height_norm = time / diff(ylims);
    
    % Set annotation line position
    line_position = [axpos(1) - gap, axpos(2), 0, axpos(4) * line_height_norm];
    h_scaleline = annotation(get(ax, 'Parent'), 'line', 'Position', line_position, 'LineWidth', 3);
    
    % Set label position
    text_x = axpos(1) - 2*gap;
    text_y = axpos(2) + axpos(4) * line_height_norm / 2;
    h_scalelabel = annotation(get(ax, 'Parent'), 'textbox', ...
        'Position', [text_x, text_y, 0, 0], 'String', tstring, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FitBoxToText', 'on', 'EdgeColor', 'none', 'BackgroundColor', 'none', ...
        'Rotation', 90);
    
    % Add listener for zoom/pan
    addlistener(handle(ax), findprop(handle(ax), 'YLim'), 'PostSet', ...
        @(~,~) yscale_line(ax, time, gap, h_scaleline, h_scalelabel));
end

%************************************************************
%                   LISTENER CALLBACKS
%************************************************************
function xscale_line(ax, time, gap, hline, hlabel)
    % Adjust x-scale line when XLim changes
    axpos = get(ax, 'Position');
    line_width = time / diff(xlim(ax));
    line_position = [axpos(1), axpos(2) - gap, axpos(3) * line_width, 0];
    set(hline, 'Position', line_position);
    set(hlabel, 'Position', [axpos(1) + axpos(3)/2*line_width, axpos(2)-2*gap, 0, 0]);
end

function yscale_line(ax, time, gap, hline, hlabel)
    % Adjust y-scale line when YLim changes
    axpos = get(ax, 'Position');
    ylims = ylim(ax);
    line_height_norm = time / diff(ylims);
    line_position = [axpos(1) - gap, axpos(2), 0, axpos(4) * line_height_norm];
    set(hline, 'Position', line_position);
    
    text_x = axpos(1) - 2*gap;
    text_y = axpos(2) + axpos(4) * line_height_norm / 2;
    set(hlabel, 'Position', [text_x, text_y, 0, 0]);
end

end
