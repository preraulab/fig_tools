function [rows, cols] = squarest_subplots(num, landscape)
%SQUAREST_SUBPLOTS  Return the most-square rows/cols for N subplots
%
%   Usage:
%       [rows, cols] = squarest_subplots(num)
%       [rows, cols] = squarest_subplots(num, landscape)
%
%   Inputs:
%       num       : integer - number of plots -- required
%       landscape : logical - landscape (wider than tall) if true (default: true)
%
%   Outputs:
%       rows : integer - number of rows
%       cols : integer - number of columns
%
%   Example:
%       [r, c] = squarest_subplots(6);         % 2, 3
%       [r, c] = squarest_subplots(9, false);  % portrait
%
%   See also: subplot, figdesign
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

if nargin == 1
    landscape = true;  % Default to landscape orientation
end

switch num
    case 1
        rows = 1;
        cols = 1;
    case 2
        rows = 1;
        cols = 2;
    case 3
        rows = 1;
        cols = 3;
    case 4
        rows = 2;
        cols = 2;
    case 5
        rows = 2;
        cols = 3;
    case 6
        rows = 2;
        cols = 3;
    case 7
        rows = 2;
        cols = 4;
    case 8
        rows = 2;
        cols = 4;
    case 9
        rows = 3;
        cols = 3;
    case 10
        rows = 2;
        cols = 5;
    otherwise
        % Find the configuration that minimizes empty space and maximizes
        % squareness
        c = [1:ceil(sqrt(num)); ceil(num ./ (1:ceil(sqrt(num))))];
        [~, ind] = min(diff(c) / 2 + 2 * (prod(c) - num));
        rows = min(c(:, ind));
        cols = max(c(:, ind));
end

% Flip rows and columns if portrait orientation
if ~landscape
    temp = rows;
    rows = cols;
    cols = temp;
end
end
