function [h_title, axbig] = outertitle(ax, title_str, varargin)
%OUTERTITLE  Plot a big title on the outside of an axis grid
%
%   Usage:
%       [h_title, axbig] = outertitle(axs, title_str, 'Name', Value, ...)
%       outertitle()   % runs demo
%
%   Inputs:
%       axs       : array of axes handles -- required
%       title_str : char - title text -- required
%
%   Name-Value Pairs:
%       <title options> : any additional name-value pairs forwarded to title()
%                         (default: {'FontSize',20,'FontWeight','bold'})
%
%   Outputs:
%       h_title : title handle
%       axbig   : parent (overlay) axes handle
%
%   Example:
%       outertitle(ax, 'My Title', 'fontsize', 30);
%
%   See also: outerlabels, figdesign, title
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main

if nargin == 0
    figure
    ax = figdesign(3,2,'type','usletter','margins',[.05 .1 .14 .1 .05]);
    title_str = 'Title';
end

if isempty(varargin)
    varargin = {'FontSize', 20, 'FontWeight', 'bold'};
end

%Force the units to be normalized
set(gcf,'units','normalized');
set(ax,'units','normalized');

%Get outer positions
pos = cat(1,ax.OuterPosition);

%Get key positions
bottom_x = min(pos(:,1));
bottom_y = min(pos(:,2));
width = max(pos(:,1) + pos(:,3)) - bottom_x;
height = max(pos(:,2) + pos(:,4)) - bottom_y;

%Create giant axes for outerlabel creation
axbig = axes('units','normalized','position',[bottom_x, bottom_y, width, height]);

%Make axes
h_title = title(title_str,varargin{:});


%Hide big axis
axbig.Visible = 'off';
h_title.Visible = 'on';
h_title.VerticalAlignment = "bottom";

