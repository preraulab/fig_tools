function [popfig_h, popax_h]=slicepopup(mainfig_h, mainax_h, x_vals, y_vals, data, x_label, y_label, z_label, slicedir, vis_on, popax_h)
%SLICEPOPUP  Create an interactive popup window that shows 2-D image slices on mouse hover
%
%   Usage:
%       [popfig_h, popax_h] = slicepopup(mainfig_h, mainax_h, x_vals, y_vals, data, ...
%                                        x_label, y_label, z_label, slicedir, vis_on, popax_h)
%
%   Inputs:
%       mainfig_h : figure handle - main figure -- required
%       mainax_h  : axes handle - axis on main figure containing the 2-D image -- required
%       x_vals    : 1xM double - x coordinates (columns) -- required
%       y_vals    : 1xN double - y coordinates (rows) -- required
%       data      : NxM double - image data; if empty, read from the axis image -- required
%       x_label   : char - x-axis label -- required
%       y_label   : char - y-axis label -- required
%       z_label   : char - z / popup data label -- required
%       slicedir  : 'x' or 'y' - slice direction -- required
%       vis_on    : logical - initial popup visibility (default: true)
%       popax_h   : axes handle - popup axis (default: creates new figure)
%
%   Outputs:
%       popfig_h : figure handle - popup figure
%       popax_h  : axes handle - popup axis
%
%   See also: imagesc, windowbuttonmotionfcn
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿
%        Source: https://github.com/preraulab/labcode_main
%-----------------------------------------------------------
%                    SETUP POPUP WINDOW
%-----------------------------------------------------------

if nargin<11 || isempty(popax_h)
    %Set initial popup visibility
    if vis_on
        %Create popup and save handle
        popfig_h=figure('position',[0 0 500 400],'visible','on');
    else
        %Create popup and save handle
        popfig_h=figure('position',[0 0 500 400],'visible','off');
    end
    
    %Get popup axes handle
    popax_h=gca;
else
    popfig_h=get(popax_h,'parent');
end

%Get handle of the popup title
pop_title=title('');

%Get data if empty
if isempty(data)
    hIm = findall(mainax_h,'type','image');
    assert(isscalar(hIm),'More than one image found in axis. Use specific image handle');
    assert(~isempty(hIm),'No image found!');
    
    data = hIm.CData;
    y_vals = hIm.YData;
    x_vals = hIm.XData;
else
    hIm = [];
end

%Determine which way the data is sliced 1=y 0=x
datadir=strcmp(slicedir,'y');

%Set popup y limits to be be based on the z-values of the data
% set(popax_h,'nextplot','replacechildren','ylim',[min(data_vect) max(data_vect)]);
set(popax_h,'nextplot','replacechildren');
if datadir
    set(popax_h,'xlim',[min(y_vals),max(y_vals)],'ylim',prctile(data(:),[.5 99.5]));
else
    set(popax_h,'ylim',[min(x_vals), max(x_vals)],'xlim',prctile(data(:),[.5 99.5]));
end

%Set the appropriate labels for the popup
if datadir
    disp_label=y_label; %popup x-label
    t_label=x_label; %title label
else
    disp_label=x_label; %popup x-lable
    t_label=y_label; %title label
end

%Set the main figure axes
xlabel(disp_label);
ylabel(z_label);

%-----------------------------------------------------------
%                SETUP MENUS AND CALLBACKS
%-----------------------------------------------------------
%Call the plotting function every time mouse is moved over the main window
set(mainfig_h,'windowbuttonmotionfcn',{@plot_slicedata,mainfig_h, mainax_h, popax_h,popfig_h, x_vals, y_vals, data, datadir, pop_title, t_label, hIm});

%Add menu on main axes
m=uimenu(mainfig_h,'Label','Popup Tools');
%Toggle Popup
uimenu(m,'Label','Toggle Popup Axes','callback',{@togglevis,popfig_h},'accelerator','u');
%Change axes
uimenu(m,'Label','Change Popup Axes','callback',{@changeaxes,popax_h},'accelerator','l');

%Make menu on popup axes
v=uimenu(popfig_h,'Label','Popup Tools');
%Toggle Popup
uimenu(v,'Label','Toggle Popup','callback',{@togglevis,popfig_h},'accelerator','u');
%Change axes
uimenu(v,'Label','Change Popup Axes','callback',{@changeaxes,popax_h},'accelerator','l');

%Make sure everything closes properly
set(popfig_h,'closerequestfcn',{@togglevis,popfig_h});
set(mainfig_h,'closerequestfcn',@(x,y)delete([mainfig_h, popfig_h]))


%***********************************************************
%***********************************************************
%                 POPUP WINDOW CALLBACKS
%***********************************************************
%***********************************************************

%-----------------------------------------------------------
%                   TOGGLE POPUP VISIBILITY
%-----------------------------------------------------------
function togglevis(~, ~, popfig_h)
%Toggles the current window if necessary
if nargin==0
    popfig_h=gcf;
end

%Toggles the current visibility of the popup
if strcmp(get(popfig_h,'visible'),'on')
    set(popfig_h,'visible','off');
else
    set(popfig_h,'visible','on');
end

%Resets focus to the main window
set(0,'currentfigure',get(get(gcbo,'parent'),'parent'));

%-----------------------------------------------------------
%                  PLOTS SLICE DATA
%-----------------------------------------------------------
function plot_slicedata(~, ~, mainfig_h, mainax_h, popax_h, popfig_h, x_vals, y_vals, data, datadir, pop_title, t_label, hIm)
if strcmp(popfig_h.Visible,'off')
    return;
end

%Handle change in data
if isempty(data) || (~isempty(hIm) && ~all(size(hIm.CData) == size(data)))
    hIm = findall(mainax_h,'type','image');
    assert(isscalar(hIm),'More than one image found in axis. Use specific image handle');
    
    data = hIm.CData;
    y_vals = hIm.YData;
    x_vals = hIm.XData;
    
    set(mainfig_h,'windowbuttonmotionfcn',{@plot_slicedata,mainfig_h, mainax_h, popax_h, x_vals, y_vals, data, datadir, pop_title, t_label});
end

%Get the current mousepoint within the main axes
pt=get(mainax_h(1),'currentpoint');

%Plot the slice data based on the slice direction
if datadir %if y slice
    %Get the closest x-value to mouse point
    [~, i]=min(abs(x_vals-pt(1,1)));
    
    %Plot slice and update title
    plot(popax_h,y_vals,data(:,i),'linewidth',2);
    set(pop_title,'string',[t_label ' = ' num2str(x_vals(i))]);
else %if x slice
    %Get the closest x-value to mouse point
    [~, i]=min(abs(y_vals-pt(1,2)));
    
    %Plote slice and update title
    plot(popax_h,x_vals,data(i,:),'linewidth',2);
    set(pop_title,'string',[t_label ' = ' num2str(y_vals(i))]);
end
drawnow;

%Resets focus to the main figure
set(0,'currentfigure',mainfig_h);


%-----------------------------------------------------------
%                  SET NEW AXIS LIMITS
%-----------------------------------------------------------
function changeaxes(~, ~,  popax_h)
%Prompt user for new axes
prompt={'New x-lims:','New y-lims:'};
name='Change Popup Axes';
numlines=1;
%Set defaults to current values
defaultanswer={num2str(get(popax_h,'xlim')),num2str(get(popax_h,'ylim'))};

answer=inputdlg(prompt,name,numlines,defaultanswer);

%Reset the axes based on the user input
set(popax_h,'xlim',str2num(answer{1}),'ylim',str2num(answer{2})); %#ok<*ST2NM>
