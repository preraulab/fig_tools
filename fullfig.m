function h=fullfig(h)
%FULLFIG  Generate a full-screen figure
%
%   Usage:
%       h = fullfig()
%       h = fullfig(h)
%
%   Inputs:
%       h : figure handle (default: new figure)
%
%   Outputs:
%       h : figure handle
%
%   Example:
%       fullfig;
%       plot(randn(1000,1));
%
%   See also: pagefig, figure
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main

if nargin==0
    h=figure;
end
set(h,'units','normalize','position',[0 0 1 1]);