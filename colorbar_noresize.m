function c = colorbar_noresize(varargin)
%COLORBAR_NORESIZE  Add a colorbar without resizing the parent axes
%
%   Usage:
%       c = colorbar_noresize()
%       c = colorbar_noresize(ax, ...)
%       c = colorbar_noresize(..., colorbar_args)
%
%   Inputs:
%       ax            : axes handle (default: gca)
%       colorbar_args : any additional args passed to colorbar()
%
%   Outputs:
%       c : colorbar handle
%
%   See also: colorbar, topcolorbar
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
if nargin==0 || ~strcmpi(class(varargin{1}),'matlab.graphics.axis.Axes')
    ax=gca;
else
    ax=varargin{1};
end

pos = ax.Position;
c = colorbar(ax, varargin{2:end});
ax.Position = pos;

end

