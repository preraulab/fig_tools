function new_axes = split_axis(varargin)
%SPLIT_AXIS  Split an axis into a grid of smaller axes by fractional breaks
%
%   Usage:
%       new_axes = split_axis(hbreaks, vbreaks)
%       new_axes = split_axis(hbreaks, vbreaks, gap, delete_ax)
%       new_axes = split_axis(ax, hbreaks, vbreaks, gap, delete_ax)
%       new_axes = split_axis()         % interactive mode
%       new_axes = split_axis(ax)       % interactive on specific axis
%
%   Inputs:
%       ax        : axes handle to split (default: gca)
%       hbreaks   : 1xH double - horizontal partitions summing to 1 -- required
%       vbreaks   : 1xV double - vertical partitions summing to 1 -- required
%       gap       : double - gap between new axes in normalized units (default: 0)
%       delete_ax : logical - delete the original axis (default: true)
%
%   Outputs:
%       new_axes : array of axes handles for the new subaxes
%
%   Example:
%       new_axes = split_axis([.1 .2 .4 .3], [.6 .2 .1 .1]);
%
%   See also: figdesign, stacked_plot
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main

%Run interactive mode
if nargin <= 1
    if nargin == 0
        ax = gca;
        fh = gcf;
    else
        ax = varargin{1};
        assert(isa(ax,'matlab.graphics.axis.Axes'), 'Single input must be axis handle');
        fh = get(ax,"Parent");
    end

    axes(ax)

    disp('Click to select horizontal slices, double-click/enter/escape');
    disp('then select vertical slices, double-click/enter/escape to complete.')
    disp(' ')

    %Store slices as user data
    fh.UserData.y_slices = [];
    fh.UserData.x_slices = [];

    %Set range
    xlim(ax,[0 100])
    ylim(ax,[0 100])
    set(ax,'units','normalized');

    %Run horizontal selection
    isHoriz = 1;
    line_h = yline(ax, 0);

    %Function to check for escape/enter
    set(fh,'KeyPressFcn',@handle_keys);

    %Set function to call on mouse click
    set(fh, 'WindowButtonDownFcn', {@pick_slice,  line_h, isHoriz, fh});
    set(fh, 'WindowButtonMotionFcn', {@select_slice, ax, line_h, isHoriz});
    uiwait(fh);
    delete(line_h)

    %Run vertical selection
    isHoriz = 0;
    line_h = xline(ax, 0);
    set(fh, 'WindowButtonDownFcn', {@pick_slice,  line_h, isHoriz, fh});
    set(fh, 'WindowButtonMotionFcn', {@select_slice, ax, line_h, isHoriz});
    uiwait(fh)

    delete(line_h)
    set(fh, 'WindowButtonMotionFcn',[]);
    set(fh, 'WindowButtonDownFcn', []);

    %Extract the slices and process them
    x_slices = fh.UserData.x_slices;
    y_slices = fh.UserData.y_slices;

    if isempty(x_slices)
        x_slices = 1;
    else
        x_slices = diff([0  unique(sort(x_slices/100)) 1]);
        x_slices = x_slices/sum(x_slices);
    end

    if isempty(y_slices)
        y_slices = 1;
    else
        y_slices = 1 - diff([0  unique(sort(y_slices/100)) 1]);
        y_slices = y_slices/sum(y_slices);
    end

    gap = getGapSize;
    if isempty(gap)
        gap = 0;
    end

    disp('Command call:')
    disp(regexprep(['   split_axis([' num2str(y_slices) '], [' num2str(x_slices) '], ' num2str(gap) ');'], '\s+', ' '));
    disp(' ')

    %Split the axis and exit
    split_axis(ax,y_slices,x_slices, gap);
    return;
end

%Parse possible axes input.
[ax, args, ~] = axescheck(varargin{:});

% Get handle to either the requested or a new axis.
if isempty(ax)
    ax = gca;
end

%Error check
assert(length(args)>= 2,'Must have at least two arguments')

hbreaks = args{1}(:);
vbreaks = args{2}(:);

if length(args)<3 || isempty(args{3})
    gap = 0;
else
    gap = args{3};
end

if length(args)<4 || isempty(args{4})
    delete_ax = true;
else
    delete_ax = args{3};
end

%Normalize axis
ax.Units = 'normalized';

%Error check
%NOTE: This check is due to the likelihood of floating point approximation
%error. e.g. sum([.3 .6 .1]) does not equal 1 but sum([.1 .3 .6])
%This is due to inexact floating point representation of certain numbers,
%the error which may or may not cancel out depending on order of operations
%See: https://dl.acm.org/doi/pdf/10.1145/103162.103163 for more info
assert(abs(sum(vbreaks))-1<1e-15, 'Sum of vertical breaks must be equal to 1');
assert(abs(sum(hbreaks))-1<1e-15, 'Sum of horizontal breaks must be equal to 1');

vbreaks = vbreaks/sum(vbreaks);
hbreaks = hbreaks/sum(hbreaks);

%Get positions of original axis
ax_left = ax.Position(1);
ax_bottom = ax.Position(2);
ax_width = ax.Position(3);
ax_height = ax.Position(4);

Nv = length(vbreaks);
Nh = length(hbreaks);

%Counter for new axes
c = 1;

%Loop through all the partitions
for hh = 1:Nh
    for vv = 1:Nv
        %Create the new axis
        ax_new = axes;

        %Update left
        if vv == 1
            ax_new.Position(1) = ax_left;
        else
            ax_new.Position(1) = ax_left + sum(vbreaks(1:vv-1))*ax_width;
        end

        %Update bottom
        ax_new.Position(2) = ax_bottom+ax_height*sum(hbreaks(hh+1:end));

        %Update width/height
        ax_new.Position(3) = ax_width*(vbreaks(vv))-gap/2;
        ax_new.Position(4) = ax_height*(hbreaks(hh))-gap/2;

        %%Good for debugging
        % ax_new.Color = rand(1,3);
        % title(num2str(c))

        %Add to output vector
        new_axes(c) = handle(ax_new); %#ok<AGROW>
        c = c+1;
    end
end

%Hides original axis
if delete_ax
    delete(ax);
end
end

function select_slice(~,~,ax, line_h, isHoriz)
%Get the current point from the mouse
C = get(ax, 'CurrentPoint');
x = C(1,1);
y = C(1,2);
xl = xlim;
yl = ylim;

%Set key spots to lock on
key_spots = [.05 .1 .2 .25 .3 1/3 .4 .5 .6 2/3 .7 .75 .8 .9 .95];
%Tolerance for key spots
tol = .01;

%Contain line values
if x<xl(1)
    x = xl(1);
end

if x>xl(2)
    x = xl(2);
end

if y<yl(1)
    y = yl(1);
end

if y>yl(2)
    y = yl(2);
end

%Get the percentage of the line
px = (x-xl(1))/diff(xl);
py = (y-yl(1))/diff(yl);

%Find the closest hot spot
[dxkey, closest_keyx] = min(abs(px-key_spots));
[dykey, closest_keyy] = min(abs(py-key_spots));

%Check for horizontal line
if isHoriz
    %Check for lock
    if dykey<tol
        py_close = key_spots(closest_keyy);
        y = py_close*diff(yl)+yl(1);

        line_h.LineWidth = 3;
        line_h.Color = 'm';
    else
        line_h.LineWidth = 1;
        line_h.Color = 'k';
        py_close = py;
    end

    line_h.Value = y;
    title(ax, [num2str(py_close*100,3), '%'],'FontSize',15);
else
    %Check for lock
    if dxkey<tol
        px_close = key_spots(closest_keyx);
        x = px_close*diff(xl)+xl(1);

        line_h.LineWidth = 3;
        line_h.Color = 'm';
    else
        line_h.LineWidth = 1;
        line_h.Color = 'k';
        px_close = px;
    end

    line_h.Value = x;
    title(ax, [num2str(px_close*100,3), '%'],'FontSize',15);
end
end

%Select and save the picked slice
function pick_slice(~,~,line_h, isHoriz, fh)
if isHoriz
    y_val = line_h.Value(1);
    fh.UserData.y_slices = [fh.UserData.y_slices y_val];
    yline(line_h.Value(1));
else
    x_val = line_h.Value;
    fh.UserData.x_slices = [fh.UserData.x_slices x_val];
    xline(line_h.Value);
end

%Finds a double click
if strcmpi(get(fh,'selectiontype'),'open')
    uiresume(fh);
end
end

%Handle selection via enter/escape
function handle_keys(~,event)
switch event.Key
    case {'return','escape'}
        uiresume(gcf);
end
end

function gap = getGapSize
% Create the figure for the popup window
fig = uifigure('Name', 'Input Gap Size', 'Position', [500 500 300 150]);

% Create the label for the input field
lbl = uilabel(fig, 'Position', [20 90 100 30], 'Text', 'Gap Size (0-1):');

% Create the edit field for entering the gap size
gapInput = uieditfield(fig, 'numeric', 'Position', [130 95 100 30]);

% Create a button to confirm the input
btn = uibutton(fig, 'Text', 'Submit', 'Position', [100 40 100 30], ...
    'ButtonPushedFcn', @(btn,event) checkGap(gapInput, fig));

% Pause code execution until the figure is closed
uiwait(fig);

% Check if the figure was closed with a valid gap value assigned
if isvalid(fig)
    % Get the gap value from the figure’s UserData
    gap = fig.UserData;
    close(fig);  % Close the figure if valid input
else
    gap = NaN;  % Handle the case where the figure was closed without input
end
end

function checkGap(gapInput, fig)
% Get the value entered by the user
gap = gapInput.Value;

% Check if the value is between 0 and 1
if gap >= 0 && gap <= 1 
    % Store the gap value in the figure's UserData
    fig.UserData = gap;
    % Resume the execution of the main script
    uiresume(fig);
else
    % If invalid, show an error message
    uialert(fig, 'Please enter a value between 0 and 1.', 'Invalid Input');
end
end
