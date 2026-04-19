function pos = get_clicks(varargin)
%GET_CLICKS  Capture mouse click coordinates on a figure axis
%
%   Usage:
%       pos = get_clicks()
%       pos = get_clicks(num_clicks)
%       pos = get_clicks(h_ax)
%       pos = get_clicks(h_ax, num_clicks)
%
%   Inputs:
%       h_ax       : axes handle (default: gca)
%       num_clicks : integer - number of clicks to capture (default: 1)
%
%   Outputs:
%       pos : num_clicks x 2 double - (x, y) coordinates per click
%
%   Example:
%       pos = get_clicks(3);
%
%   See also: ginput, waitforbuttonpress, iptPointerManager
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main

% Set default values for input arguments
if nargin == 0
    h_ax = gca;         % Use the current axis
    num_clicks = 1;     % Capture one click
end

% Process input arguments
if nargin == 1
    h_ax = gca;         % Use the current axis
    num_clicks = varargin{1};
end

if nargin == 2
    h_ax =  varargin{1};
    num_clicks = varargin{2};
end

% Get the figure handle from the axis
h_fig = h_ax.Parent;

% Initialize the position matrix
pos = zeros(num_clicks, 2);

% Set pointer behavior to crosshair
iptPointerManager(h_fig);
iptSetPointerBehavior(h_ax, @(hfig, currentPoint)set(hfig, 'Pointer', 'cross'));

% Capture mouse clicks
clicks = 0;
while clicks < num_clicks
    w = waitforbuttonpress;
    if ~w
        clicks = clicks + 1;
        p = get(h_ax, 'CurrentPoint');
        pos(clicks, :) = p(1, 1:2);
    end
end

% Reset pointer behavior to arrow
iptSetPointerBehavior(h_ax, @(hfig, currentPoint)set(hfig, 'Pointer', 'arrow'));
end
