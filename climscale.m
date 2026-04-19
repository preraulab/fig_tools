function clims_new = climscale(hObj, ptiles, outliers)
%CLIMSCALE  Rescale image color limits to percentile bounds, optionally removing outliers
%
%   Usage:
%       clims_new = climscale()
%       clims_new = climscale(hObj)
%       clims_new = climscale(hObj, ptiles, outliers)
%       climscale(ptiles)      % single numeric arg interpreted as ptiles
%       climscale(outliers)    % single logical arg interpreted as outliers flag
%
%   Inputs:
%       hObj     : axes or image handle (default: gca)
%       ptiles   : 1x2 double - scaling percentiles (default: [5 98])
%       outliers : logical - remove outliers via isoutlier before scaling (default: true)
%
%   Outputs:
%       clims_new : 1x2 double - new color-limits applied to the axis
%
%   Example:
%       imagesc(peaks(500));
%       climscale;
%
%   See also: clims, caxis, isoutlier, prctile
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
if nargin == 1
    if isa(hObj,'matlab.graphics.primitive.Image') || isa(hObj,'matlab.graphics.axis.Axes')
        ptiles =[5 98];
        outliers = true;
    elseif issorted(hObj) && isnumeric(hObj)
        ptiles = hObj;
        hObj = gca;
        outliers = true;
    elseif islogical(hObj)
        outliers = hObj;
        hObj = gca;
        ptiles =[5 98];
    else
        error('Single input must be object, ptiles, or logical');
    end
else
%Set default current axis
if nargin==0 || isempty(hObj)
    hObj=gca;
end

%Set default percentiles
if nargin<2 || isempty(ptiles)
    ptiles=[5 98];
end

%Set default percentils
if nargin<3 || isempty(outliers)
    outliers = true;
end
end

assert(ishandle(hObj) || isa(hObj,'matlab.graphics.primitive.Image') || isa(hObj,'matlab.graphics.axis.Axes'),['First input must be axis or image handle. Input was ' class(hObj)])
assert(issorted(ptiles) && isnumeric(ptiles), 'Percentiles must be monotically increasing and numeric');
assert(islogical(outliers), 'Outliers must be logical');


%Get color data
if isa(hObj,'matlab.graphics.primitive.Image')
    hIm = hObj;
    hAx = get(hIm, 'parent');
else
    hAx = hObj;
    hIm = findall(hAx,'type','image');
    assert(length(hIm) == 1,'More than one image found in axis. Use specific image handle');
end

%Get color data
data = hIm.CData(:);

%Make sure it is not a flat image
assert(range(data)>0,'Image data are all equal');

%Handle massive images
N = length(data);
if N > 1e9
    warning('Data too large to efficiently compute percentile. Using random sampling.');
    data = data(randi(N, 1, min(100000, N)));
end

%Find poorly formed data
if ~outliers
    bad_inds = isnan(data) | isinf(data);
else %Remove outliers if selected
    bad_inds = isnan(data) | isinf(data) | isoutlier(data);
end

%Compute color limits
clims_new = prctile(data(~bad_inds), ptiles);

if clims_new(1) == clims_new(2)
    return;
end

%Update axis scale
set(hAx,'CLim',clims_new);
