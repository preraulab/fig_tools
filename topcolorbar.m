function [lab, c] = topcolorbar(w, h, vgap)
%TOPCOLORBAR  Create a colorbar positioned at the top of the current axes
%
%   Usage:
%       [lab, c] = topcolorbar
%       [lab, c] = topcolorbar(w, h)
%       [lab, c] = topcolorbar(w, h, vgap)
%
%   Inputs:
%       w    : double - colorbar width in normalized units (default: 0.2)
%       h    : double - colorbar height in normalized units (default: 0.01)
%       vgap : double - vertical gap between plot and colorbar (default: 0.01)
%
%   Outputs:
%       lab : handle to the colorbar label
%       c   : handle to the colorbar
%
%   Example:
%       [lab, c] = topcolorbar(0.3, 0.02, 0.02);
%
%   See also: colorbar, get, set
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

colorbar('off');  % Remove any existing colorbars
axpos = get(gca, 'Position');  % Get the position of the current axes

if nargin < 1
    w = 0.2;  % Default width of the colorbar
end

if nargin < 2
    h = 0.01;  % Default height of the colorbar
end

if nargin < 3
    vgap = 0.01;  % Default vertical gap between plot and colorbar
end

c = colorbar('northoutside', 'Units', 'normalized');  % Create the colorbar

cpos(4) = h;
cpos(3) = w;
cpos(2) = axpos(2) + axpos(4) + vgap;
cpos(1) = axpos(1) + axpos(3) - w;

set(c, 'Position', cpos);  % Set the position of the colorbar

lab = get(c, 'Label');  % Get the label of the colorbar
labpos = get(lab, 'Position');  % Get the position of the label
labpos(2) = 0.8 * labpos(2);  % Adjust the vertical position of the label
set(lab, 'String', 'Power (dB)', 'Position', labpos);  % Set the label text and position
end
