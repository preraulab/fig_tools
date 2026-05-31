function lab_handle = letter_label(fig_h, ax_h, labstr, labdir, fontsize, gaps)
%LETTER_LABEL  Add a figure-label letter annotation next to an axis
%
%   Usage:
%       lab_handle = letter_label()
%       lab_handle = letter_label(fig_h, ax_h, labstr, labdir, fontsize, gaps)
%
%   Inputs:
%       fig_h    : figure handle (default: gcf)
%       ax_h     : axes handle (default: gca)
%       labstr   : char - label text (default: 'A')
%       labdir   : char - 'left'/'l' or 'right'/'r' side of the axis (default: 'l')
%       fontsize : double - font size (default: 30)
%       gaps     : 1x2 double - [vertical horizontal] gaps in normalized units (default: [.03 .03])
%
%   Outputs:
%       lab_handle : annotation handle for the textbox
%
%   Example:
%       letter_label(gcf, gca, 'B', 'left', 25);
%
%   See also: annotation, outertitle
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

%Set defaults
if nargin < 1
    fig_h = gcf;
end

if nargin<2
    ax_h = gca;
end

if nargin<3
    labstr = 'A';
end

if nargin<4
    labdir = 'l';
end

if nargin < 5
    fontsize = 30;
end

if nargin<6
    gaps = [.03 .03];
end


% Force everything to be normalized
set(fig_h,'units','normalized');
set(ax_h,'Units','normalized');

%Get the position of the axis in the figure space
axpos = ax_h.Position;

%Set large textbox size
W = .05;
H = .05;

%Set textbox position as a function of direction.
% The textbox is fixed W x H. Position is clamped to [0, 1] for
% MATLAB annotation's Position constraint. HorizontalAlignment
% flips to 'left' (left labels) or 'right' (right labels) when the
% box would have needed to extend off the figure edge so the
% visible glyph sits at the box edge nearer the figure boundary
% rather than saturating at x = W.
y_pos = max(min(axpos(2) + axpos(4) + gaps(1), 1), 0);
W_pos = max(min(W, 1), 0);
H_pos = max(min(H, 1), 0);
switch lower(labdir)
    case {'left','l'}
        box_x_raw = axpos(1) - W - gaps(2);
        box_x     = max(min(box_x_raw, 1 - W_pos), 0);
        if box_x_raw < 0
            halign = 'left';
        else
            halign = 'right';
        end
        labpos = [box_x, y_pos, W_pos, H_pos];
    case {'right','r'}
        box_x_raw = axpos(1) + axpos(3) + gaps(2);
        box_x     = max(min(box_x_raw, 1 - W_pos), 0);
        if box_x_raw + W > 1
            halign = 'right';
        else
            halign = 'left';
        end
        labpos = [box_x, y_pos, W_pos, H_pos];
    otherwise
        error('Label direction must be ''left'' or ''right''');
end


% Create textbox for figure labe;
lab_handle = annotation(fig_h,'textbox',...
    labpos,...
    'String',labstr,...
    'HorizontalAlignment',halign,...
    'VerticalAlignment','bottom',...
    'FontSize',fontsize,...
    'LineStyle','none',...
    'margin',0,...
    'FontName','Helvetica Neue',...
    'FitBoxToText','off');

