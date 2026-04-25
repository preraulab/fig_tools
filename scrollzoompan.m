function [zslider, pslider, zedit, pedit, zlabel, plabel, zlstnr, plstnr] = scrollzoompan(ax, dir, zoom_fcn, pan_fcn, bounds)
%SCROLLZOOMPAN  Add interactive scroll-wheel and keyboard pan/zoom controls to an axis
%
%   Usage:
%       [zslider, pslider, zedit, pedit, zlabel, plabel, zlstnr, plstnr] = ...
%           scrollzoompan(ax, dir, zoom_fcn, pan_fcn, bounds)
%
%   Inputs:
%       ax       : axes handle (default: gca)
%       dir      : char - 'x' or 'y' pan/zoom direction (default: 'x')
%       zoom_fcn : function handle - optional callback after zooming (default: [])
%       pan_fcn  : function handle - optional callback after panning (default: [])
%       bounds   : 1x2 numeric or datetime - optional [min max] data limits (default: [nan nan])
%
%   Outputs:
%       zslider : slider handle - zoom width
%       pslider : slider handle - pan center
%       zedit   : edit-box handle - zoom value display/input
%       pedit   : edit-box handle - pan value display/input
%       zlabel  : text handle - 'Zoom' label
%       plabel  : text handle - 'Pan' label
%       zlstnr  : listener handle - continuous updates for zoom slider
%       plstnr  : listener handle - continuous updates for pan slider
%
%   Notes:
%       - Mouse wheel pans; Shift + wheel zooms.
%       - Arrow keys pan/zoom unless an edit box has focus.
%       - For datetime axes, pan edit uses MM/DD/YY HH:mm:ss format,
%         and zoom edit uses HH:MM:SS duration.
%       - The figure is grown downward on first call so controls are
%         added below existing content rather than overlapping it.
%
%   Example:
%       x = linspace(0,100,10000); plot(x, sin(x));
%       scrollzoompan(gca,'x');
%
%   See also: zoom, pan, addlistener
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%% ------------------------- DEFAULT ARGUMENT HANDLING -------------------------
% If no axis is provided, default to current axis
if nargin==0, ax = gca; end

% Default zoom/pan direction
if nargin<2, dir='x'; end

% Optional callbacks default to empty
if nargin<3, zoom_fcn = []; end
if nargin<4, pan_fcn = []; end

% Optional bounds default to NaNs (ignored)
if nargin<5, bounds = [nan nan]; end

% Get the parent figure of the axis
fig_h = ancestor(ax,'figure');
if ~isa(fig_h,'matlab.ui.Figure')
    fig_h = gcf;
end

%% ------------------------- DETERMINE AXIS LIMITS -------------------------
% Determine if the axis is time-based (datetime)
if strcmpi(dir,'x')
    val_min = ax.XLim(1);
    val_max = ax.XLim(2);
    isdataax = isdatetime(ax.XLim(1));
else
    val_min = ax.YLim(1);
    val_max = ax.YLim(2);
    isdataax = isdatetime(ax.YLim(1));
end

% Override limits if user supplied bounds (ismissing handles both NaN and NaT)
if ~ismissing(bounds(1)), val_min = bounds(1); end
if ~ismissing(bounds(2)), val_max = bounds(2); end

% Convert datetime to seconds offset (internal numeric representation)
if isdataax
    dt_min = val_min;
    dt_max = val_max;
    val_min = 0;
    val_max = seconds(dt_max - dt_min);
end

%% ------------------------- EXPAND FIGURE FOR CONTROLS -------------------------
% Grow the figure at the bottom so the sliders/edits are added beneath
% the existing content rather than overlapping it. Existing children are
% pinned in pixel space so they stay at the same on-screen position.
% Only expand once per figure, even if scrollzoompan is called multiple times.
if ~isappdata(fig_h,'scrollzoompan_expanded')
    setappdata(fig_h,'scrollzoompan_expanded',true);

    old_fig_units = fig_h.Units;
    fig_h.Units = 'pixels';
    fpos = fig_h.Position;

    % Added height: ctrl_h/(old_h+ctrl_h) = 0.10, so the bottom 10% of the
    % resized figure matches the normalized layout used below.
    ctrl_h_px = fpos(4) / 9;

    % Record existing children in pixel units so their screen position is preserved
    kids = fig_h.Children;
    kid_units = cell(size(kids));
    kid_pos   = cell(size(kids));
    for k = 1:numel(kids)
        c = kids(k);
        try
            if isprop(c,'Units') && isprop(c,'Position') && ~isempty(c.Position)
                kid_units{k} = c.Units;
                c.Units = 'pixels';
                kid_pos{k}   = c.Position;
            end
        catch
            kid_units{k} = '';
        end
    end

    % Grow upward only: preserve the figure's on-screen anchor (bottom-left)
    % and its width, extending the top edge by ctrl_h_px
    fig_h.Position = [fpos(1) fpos(2) fpos(3) fpos(4)+ctrl_h_px];

    % Shift each child up by ctrl_h_px inside the figure so the new bottom
    % strip is free for the controls, then restore original units
    for k = 1:numel(kids)
        if ~isempty(kid_units{k})
            try
                p = kid_pos{k};
                kids(k).Position = [p(1) p(2)+ctrl_h_px p(3) p(4)];
                kids(k).Units    = kid_units{k};
            catch
            end
        end
    end

    fig_h.Units = old_fig_units;
end

%% ------------------------- CREATE SLIDERS -------------------------
% Vertical offset between zoom and pan UI bars
shift = 0.04;

% Protect against degenerate (near-zero) ranges where min >= max would error
zslider_min = 1e-5;
zslider_max = max(val_max - val_min, zslider_min*2);
zslider_val = min(max(val_max - val_min, zslider_min), zslider_max);

% Zoom slider (controls zoom width)
zslider = uicontrol(fig_h,'style','slider','units','normalized',...
    'position',[0.07 0.026 0.83 0.023],...
    'min',zslider_min,'max',zslider_max,'value',zslider_val);

% Pan slider (controls zoom center)
pslider = uicontrol(fig_h,'style','slider','units','normalized',...
    'position',[0.07 0.026+shift 0.83 0.023],...
    'min',val_min,'max',val_max,'value',(val_min+val_max)/2);

%% ------------------------- CREATE EDIT BOXES -------------------------
% Zoom edit box
zedit = uicontrol(fig_h,'style','edit','units','normalized',...
    'position',[0.91 0.0147 0.0823 0.0422]);

% Pan edit box
pedit = uicontrol(fig_h,'style','edit','units','normalized',...
    'position',[0.91 0.0147+shift 0.0823 0.0422]);

% Store last valid values to recover from invalid edits
prev_zval = zslider.Value;
prev_pval = pslider.Value;

% Initialize edit box displays
update_edits();

%% ------------------------- LABELS -------------------------
zlabel = uicontrol(fig_h,'style','text','string','Zoom','units','normalized',...
    'position',[0.0086 0.0071 0.0628 0.0449],...
    'fontsize',12,'HorizontalAlignment','left','BackgroundColor',fig_h.Color);

plabel = uicontrol(fig_h,'style','text','string','Pan','units','normalized',...
    'position',[0.0086 0.0071+shift 0.0628 0.0449],...
    'fontsize',12,'HorizontalAlignment','left','BackgroundColor',fig_h.Color);

%% ------------------------- SLIDER LISTENERS -------------------------
% Enable continuous updates as the slider is dragged
zlstnr = addlistener(zslider,'ContinuousValueChange',@(src,evnt) zoom_slider_cb());
plstnr = addlistener(pslider,'ContinuousValueChange',@(src,evnt) pan_slider_cb());

% Edit box callbacks
zedit.Callback = @(src,evnt) zoom_edit_cb();
pedit.Callback = @(src,evnt) pan_edit_cb();

%% ------------------------- KEY + MOUSE EVENT HANDLERS -------------------------
% Key press: used for arrow-key panning/zooming
fig_h.WindowKeyPressFcn = @handle_keys;

% Mouse scroll: pan or zoom depending on Shift key
fig_h.WindowScrollWheelFcn = @scroll_cb;

%% ------------------------- CALLBACK FUNCTIONS -------------------------

    % --------------------------------------------------------------
    % Apply zoom when zoom slider moves
    % width = zoom window width
    % center = center of pan slider
    % --------------------------------------------------------------
    function zoom_slider_cb()
        width = zslider.Value;
        center = pslider.Value;

        % Compute tentative new limits
        newlims = center + width/2*[-1 1];

        % Keep limits within bounds
        newlims = constrain_limits(newlims,pslider.Min,pslider.Max,width);

        % Convert back to datetime if needed
        if isdataax
            axlims = dt_min + seconds(newlims);
        else
            axlims = newlims;
        end

        % Apply limits
        if strcmpi(dir,'x')
            ax.XLim = axlims;
        else
            ax.YLim = axlims;
        end

        prev_zval = zslider.Value;
        update_edits();

        if ~isempty(zoom_fcn), feval(zoom_fcn); end
    end

    % --------------------------------------------------------------
    % Apply pan when pan slider moves
    % --------------------------------------------------------------
    function pan_slider_cb()
        center = pslider.Value;
        width = zslider.Value;

        % Compute tentative new limits
        newlims = center + width/2*[-1 1];

        % Constrain within axis limits
        newlims = constrain_limits(newlims,pslider.Min,pslider.Max,width);

        % Convert back to datetime if necessary
        if isdataax
            axlims = dt_min + seconds(newlims);
        else
            axlims = newlims;
        end

        % Apply
        if strcmpi(dir,'x')
            ax.XLim = axlims;
        else
            ax.YLim = axlims;
        end

        prev_pval = pslider.Value;
        update_edits();

        if ~isempty(pan_fcn), feval(pan_fcn); end
    end

%% ------------------------- ZOOM EDIT CALLBACK (WITH WARNING) -------------------------
    function zoom_edit_cb()
        str = zedit.String;
        if isdataax
            try
                dur = duration(str);
                val = seconds(dur);
            catch
                warning(['Invalid Zoom value. ', ...
                         'Zoom must be entered as a duration in the format HH:MM:SS.']);
                val = prev_zval;
            end
        else
            val = str2double(str);
            if isnan(val)
                warning('Invalid Zoom value. Zoom must be a numeric value.');
                val = prev_zval;
            end
        end

        % Clamp and apply
        val = min(max(val, zslider.Min), zslider.Max);
        zslider.Value = val;
        prev_zval = val;
        zoom_slider_cb();
    end

%% ------------------------- PAN EDIT CALLBACK (WITH WARNING) -------------------------
    function pan_edit_cb()
        str = pedit.String;
        if isdataax
            try
                dt = datetime(str,'InputFormat','MM/dd/yy HH:mm:ss');
                val = seconds(dt - dt_min);
            catch
                warning(['Invalid Pan value. ', ...
                         'Pan must be entered in the format MM/DD/YY HH:mm:ss.']);
                val = prev_pval;
            end
        else
            val = str2double(str);
            if isnan(val)
                warning('Invalid Pan value. Pan must be a numeric value.');
                val = prev_pval;
            end
        end

        % Clamp + apply
        val = min(max(val, pslider.Min), pslider.Max);
        pslider.Value = val;
        prev_pval = val;
        pan_slider_cb();
    end

%% ------------------------- UPDATE EDIT FIELD DISPLAY -------------------------
    function update_edits()
        if isdataax
            % Zoom: duration, formatted as hh:mm:ss
            zedit.String = char(duration(0,0,zslider.Value,'Format','hh:mm:ss'));

            % Pan: absolute datetime. char(datetime) honors the Format property;
            % there is no 2-arg char(dt, fmt) overload.
            dt = dt_min + seconds(pslider.Value);
            dt.Format = 'MM/dd/yy HH:mm:ss';
            pedit.String = char(dt);
        else
            zedit.String = num2str(zslider.Value);
            pedit.String = num2str(pslider.Value);
        end
    end

%% ------------------------- LIMIT CONSTRAINT HELPER -------------------------
    function newlims = constrain_limits(lims,minval,maxval,width)
        % Ensure pan/zoom region stays within required bounds
        if lims(1) < minval
            newlims = [minval minval+width];
        elseif lims(2) > maxval
            newlims = [maxval-width maxval];
        else
            newlims = lims;
        end
    end

%% ------------------------- SCROLL WHEEL HANDLER -------------------------
    function scroll_cb(~,evt)
        % Do nothing if user is editing a textbox
        obj = gco;
        if isa(obj,'matlab.ui.control.UIControl') && strcmp(obj.Style,'edit')
            return
        end

        % Read live modifier state from the figure so Shift detection does
        % not depend on a stale flag maintained across keypresses
        shift_held = any(strcmpi(fig_h.CurrentModifier,'shift'));

        % Zoom when Shift is held
        if shift_held
            val = zslider.Value*(1 - 0.025*evt.VerticalScrollCount);
            zslider.Value = min(max(val,zslider.Min),zslider.Max);
            zoom_slider_cb();
        else
            % Pan normally — additive step proportional to zoom width so
            % sensitivity is constant across the axis (multiplicative step
            % would trap the user at pslider.Value = 0 and give nonlinear
            % sensitivity everywhere else)
            step = 0.025*zslider.Value;
            val = pslider.Value - step*evt.VerticalScrollCount;
            pslider.Value = min(max(val,pslider.Min),pslider.Max);
            pan_slider_cb();
        end
    end

%% ------------------------- KEYBOARD ARROWS HANDLER -------------------------
    function handle_keys(~,evt)
        % Ignore keypresses while editing textboxes
        obj = gco;
        if isa(obj,'matlab.ui.control.UIControl') && strcmp(obj.Style,'edit')
            return
        end

        % Step size proportional to zoom width
        step = zslider.Value*2;

        switch evt.Key
            case 'rightarrow'
                pslider.Value = min(pslider.Value+step, pslider.Max);
                pan_slider_cb();
            case 'leftarrow'
                pslider.Value = max(pslider.Value-step, pslider.Min);
                pan_slider_cb();
            case 'uparrow'
                zslider.Value = min(zslider.Value*1.025, zslider.Max);
                zoom_slider_cb();
            case 'downarrow'
                zslider.Value = max(zslider.Value*0.975, zslider.Min);
                zoom_slider_cb();
        end
    end

end
