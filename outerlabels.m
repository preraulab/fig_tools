function [h_xl, h_yl, h_axbig] = outerlabels(ax,xlabel_str,ylabel_str, varargin)
%OUTERLABELS  Add big x/y labels on the outside of an axis grid
%
%   Usage:
%       [h_xl, h_yl, h_axbig] = outerlabels(axs, xlabel_str, ylabel_str, 'Name', Value, ...)
%       outerlabels()    % runs demo
%
%   Inputs:
%       axs        : array of axes handles -- required
%       xlabel_str : char - outer x-label text -- required
%       ylabel_str : char - outer y-label text -- required
%
%   Name-Value Pairs:
%       'XAxisLocation' : 'bottom' or 'top' (default: 'bottom')
%       'YAxisLocation' : 'left' or 'right' (default: 'left')
%       <label options> : any additional name-value pairs forwarded to xlabel/ylabel
%                         (default: {'FontSize',17,'FontWeight','bold'})
%
%   Outputs:
%       h_xl    : xlabel handle
%       h_yl    : ylabel handle
%       h_axbig : parent (overlay) axes handle
%
%   Example:
%       ax = figdesign(3,2);
%       [~,~,ax_big] = outerlabels(ax,'My X-Label','My Y-Label');
%
%   See also: outertitle, figdesign, xlabel, ylabel
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

if nargin == 0
    figure
    ax = figdesign(3,2,'type','usletter','margins',[.05 .1 .14 .1 .05]);
    xlabel_str = 'X Label';
    ylabel_str = 'Y Label';
end

if isempty(varargin)
    varargin = {'FontSize', 17, 'FontWeight', 'bold'};
end

%Parse inputs to extract just the xy axis locations
p = inputParser;
addOptional(p,'XAxisLocation','bottom',@(x)  any(validatestring(x,{'top','bottom'})));
addOptional(p,'YAxisLocation','left',@(x) any(validatestring(x,{'left','right'})));
p.KeepUnmatched = true;
parse(p,varargin{:});

%Save results
xloc = p.Results.XAxisLocation;
yloc = p.Results.YAxisLocation;

%Recreate varargin removing the x/y axis location name pairs
varargin = cat(2,fieldnames(p.Unmatched),struct2cell(p.Unmatched));
varargin = reshape(varargin',1, numel(varargin));

%Force the units to be normalized
set(gcf,'units','normalized');
set(ax,'units','normalized');

%Get outer positions
pos = cat(1,ax.OuterPosition);

%Get key positions
bottom_x = max(min(pos(:,1)),.05);
bottom_y = max(min(pos(:,2)),.05);
width = min(max(pos(:,1) + pos(:,3)) - bottom_x,.95);
height = min(max(pos(:,2) + pos(:,4)) - bottom_y,.95);

%Create giant axes for outerlabel creation
h_axbig = axes('units','normalized','position',[bottom_x, bottom_y, width, height]);

%Make axes
h_xl = xlabel(xlabel_str,varargin{:});
h_yl = ylabel(ylabel_str,varargin{:});

%Hide big axis
h_axbig.Visible = 'off';
h_axbig.XLabel.Visible = 'on';
h_axbig.YLabel.Visible = 'on';
h_axbig.XLabel.VerticalAlignment = "middle";
h_axbig.YLabel.VerticalAlignment = "middle";

%Set axis label location
h_axbig.XAxisLocation = xloc;
h_axbig.YAxisLocation = yloc;
