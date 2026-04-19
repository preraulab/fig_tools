function linkaxes3d(axs)
%LINKAXES3D  Link 3D camera positions and xyz limits across multiple axes
%
%   Usage:
%       linkaxes3d(axs)
%
%   Inputs:
%       axs : array of 3D axes handles -- required
%
%   Outputs:
%       none (the linkprop is attached to axs(1) via setappdata so the link
%       persists for the lifetime of the axes; multiple linked groups can
%       coexist in one session)
%
%   Example:
%       axs(1) = subplot(121); surf(peaks(500),'edgecolor','none');
%       axs(2) = subplot(122); surf(-peaks(500),'edgecolor','none');
%       linkaxes3d(axs);
%
%   See also: linkaxes, linkprop, linkcaxes
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
hlink = linkprop(axs, {'CameraPosition','CameraUpVector'});
setappdata(axs(1), 'Camera_linkprop', hlink);
linkaxes(axs, 'xyz');
