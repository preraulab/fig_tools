function linkcaxes(ax)
%LINKCAXES  Link the color limits (CLim) of multiple axes
%
%   Usage:
%       linkcaxes(ax)
%
%   Inputs:
%       ax : array of axes handles -- required
%
%   Outputs:
%       none (the linkprop is attached to ax(1) via setappdata so the link
%       persists for the lifetime of the axes)
%
%   Notes:
%       CLim applies to color-mapped graphics (images, surfaces, etc.).
%       Multiple independent linked groups can coexist in one session.
%
%   Example:
%       ax(1) = subplot(2,1,1); imagesc(peaks(100));
%       ax(2) = subplot(2,1,2); imagesc(peaks(300)*2-5);
%       linkcaxes(ax);
%
%   See also: linkprop, linkaxes, equalize_axes, caxis
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
if nargin == 0
    error('Must provide axis handles');
end

hlink = linkprop(ax, 'CLim');
setappdata(ax(1), 'CLim_linkprop', hlink);
