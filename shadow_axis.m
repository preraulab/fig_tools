function [axis_handle, shadow_handle] = shadow_axis(varargin)
%SHADOW_AXIS  Create an axis with a soft drop-shadow behind it
%
%   Usage:
%       [axis_handle, shadow_handle] = shadow_axis()
%       [axis_handle, shadow_handle] = shadow_axis('Name', Value, ...)
%
%   Name-Value Pairs:
%       'position'   : 1x4 double - axis position (default: [0.13 0.11 0.775 0.815])
%       'size'       : double - shadow spread in pixels (default: 10)
%       'distance'   : double - offset between axis and shadow in normalized units (default: 0.03)
%       'angle'      : double - shadow angle in degrees (default: -45)
%       'opacity'    : double in [0,1] - shadow opacity (default: 0.5)
%       'resolution' : double - pixel resolution of the shadow image (default: 500)
%
%   Outputs:
%       axis_handle   : axes handle - the axis for plotting
%       shadow_handle : axes handle - the shadow axis (behind)
%
%   Example:
%       [ax, sh] = shadow_axis('size', 15, 'opacity', 0.7);
%
%   See also: fspecial, imfilter
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

% Parse all the inputs
p = inputParser;

% Axis position
p.addOptional('position', [0.1300 0.1100 0.7750 0.8150]);

% Shadow size
p.addOptional('size', 10);

% Shadow distance
p.addOptional('distance', 0.03);

% Shadow angle (in degrees)
p.addOptional('angle', -45);

% Shadow opacity
p.addOptional('opacity', 0.5);

% Shadow resolution
p.addOptional('resolution', 500);

% Parse the arguments
p.parse(varargin{:});
args = p.Results;

% Set the variables from the input
position = args.position;
size = args.size;
distance = args.distance;
angle = args.angle;
opacity = args.opacity;
resolution = args.resolution;

% Get the figure background color
bgcolor = get(gcf, 'color');

% Create the shadow axes
shadow_handle = axes('position', position + [cos(angle/180*pi)*distance sin(angle/180*pi)*distance 0 0]);

% Create the shadow
% Make the image the color of the background
shadow = cat(3, ones(resolution)*bgcolor(1), ones(resolution)*bgcolor(2), ones(resolution)*bgcolor(3));

% Make the shadow and set darkness based on opacity parameter
for i = 1:3
    shadow(size:end-size, size:end-size, i) = (1-opacity) * bgcolor(i);
end

% Blur to create the shadow effect
F = fspecial('disk', size);
shadow = imfilter(shadow, F, 'replicate');

% Display the shadow
image(shadow);
set(gca, 'XTick', [], 'YTick', [], 'XColor', bgcolor, 'YColor', bgcolor);

% Create the actual axis for plotting
axis_handle = axes('Units', 'normalized', 'Position', position);
end
