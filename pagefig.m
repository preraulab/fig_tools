function h=pagefig(varargin)
%PAGEFIG  Generate a paper-sized figure (default: US-letter, portrait)
%
%   Usage:
%       h = pagefig()
%       h = pagefig(fig_handle)
%       h = pagefig(fig_handle, 'Name', Value, ...)
%
%   Inputs:
%       fig_handle : figure handle (default: new figure)
%
%   Name-Value Pairs:
%       'orient' : 'portrait' or 'landscape' (default: 'portrait')
%       'type'   : char - paper type (default: 'usletter')
%
%   Outputs:
%       h : figure handle
%
%   Example:
%       pfigh = pagefig;
%       pagefig(pfigh, 'orient', 'landscape');
%
%   See also: fullfig, figure
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
%Set optional direction input
p=inputParser;
p.addOptional('orient', 'portrait', @(x)any(validatestring(x,{'portrait','landscape'})));
p.addOptional('type', 'usletter');

if nargin==0
    h=figure;
    p.parse(varargin{:});
else
    %Allow for handle input
    if isnumeric(varargin{1})
        h=figure(varargin{1});
        p.parse(varargin{2:end});
    else
        h=figure;
        p.parse(varargin{:});
    end
end

%Get the parsed result
orientation=p.Results.orient;
paper_type=p.Results.type;

%Create figure
set(h,'paperorientation',orientation,'paperunits','inches','papertype',paper_type);

set(h,'units','inches','position',[0 0 get(gcf,'papersize')],'color','w');
set(h,'units','normalized');
