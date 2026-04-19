function fh_new = mergefigures(fh1,fh2, ratio, stacking, textshrink)
%MERGEFIGURES  Merge two existing figures into one along a chosen axis and ratio
%
%   Usage:
%       fh_new = mergefigures()                            % runs demo
%       fh_new = mergefigures(fh1, fh2, ratio, stacking, textshrink)
%
%   Inputs:
%       fh1, fh2   : figure handles - source figures -- required
%       ratio      : double in (0,1) - size fraction for fh1 (default: 0.5)
%       stacking   : char - 'LR' (left/right) or 'UD' (up/down) (default: 'LR')
%       textshrink : double - font scale factor applied to copied children (default: 0.8)
%
%   Outputs:
%       fh_new : figure handle - merged figure
%
%   Example:
%       mergefigures(fh1, fh2, 0.6, 'LR');
%
%   See also: figdesign, copyobj
%
%   ∿∿∿  Prerau Laboratory MATLAB Codebase · sleepEEG.org  ∿∿∿

if nargin == 0
    close all;
    fh1 = figure;
    imagesc(peaks(500));
    fh2 = figure;
    plot(randn(1,1000));
    
    mergefigures(fh1,fh2, .6, 'lr');
    mergefigures(fh1,fh2, .2, 'lr');
    mergefigures(fh1,fh2, .6, 'ud');
    mergefigures(fh1,fh2, .2, 'ud');
    
    delete(fh1);
    delete(fh2);
    return;
end
%% Handle inputs
if nargin<2
    error('Must input two handles to figures');
end

if ~ishandle(fh1) || ~isa(fh1,'matlab.ui.Figure')
    error('Input for f1 and f2 must be figure handles');
end

if ~ishandle(fh2) || ~isa(fh2,'matlab.ui.Figure')
    error('Input for f1 and f2 must be figure handles');
end

if nargin < 3 || isempty(ratio)
    ratio = .5;
elseif ratio<=0 || ratio>=1
    error('Ratio must be between 0 and 1');
end

if nargin<4 || isempty(stacking)
    stacking = 'LR';
end

if nargin<5 || isempty(textshrink)
    textshrink = .8;
end

switch lower(stacking)
    case 'lr'
        LRdir = true;
    case 'ud'
        LRdir = false;
    otherwise
        error('Stacking must be LR or UD');
end
%%
%Set units to normalized to make all scaling easier
set(fh1,'units','normalized');
set(fh2,'units','normalized');

%Create new figure for merged figures
fh_new=figure;
set(fh_new,'paperorientation','portrait','paperunits','inches','papertype','usletter')
set(fh_new,'units','inches','position',[0 0 get(fh_new,'papersize')],'color','w');
set(fh_new,'units','normalized');

%Get all the children and copy to the new figure
f1_children = findobj(fh1,{'Type','Axes','-or','Type','Colorbar'});
f2_children = findobj(fh2,{'Type','Axes','-or','Type','Colorbar'});

%Textbox field names to copy
tbox_fn = {'String','Color', 'FontSize','FontName','FontWeight','LineStyle','Position'};

%Add the textboxes
f1_tbox = findall(fh1,{'Type', 'TextBox'});

tb_new1 = matlab.graphics.shape.TextBox.empty(0,length(f1_tbox));
for ii = 1:length(f1_tbox)
    tb = f1_tbox(ii);
    tb_new1(ii) = annotation(fh_new,'textbox','String','TESTING123');
    
    for ff = 1:length(tbox_fn)
        tb_new1(ii).(tbox_fn{ff}) = tb.(tbox_fn{ff});
    end
end

f2_tbox = findall(fh2,{'Type', 'TextBox'});

tb_new2 = matlab.graphics.shape.TextBox.empty(0,length(f2_tbox));
for ii = 1:length(f2_tbox)
    tb = f2_tbox(ii);
    tb_new2(ii) = annotation(fh_new,'textbox','String','TESTING123');
    
    for ff = 1:length(tbox_fn)
        tb_new2(ii).(tbox_fn{ff}) = tb.(tbox_fn{ff});
    end
end


c1 = copyobj(f1_children,fh_new);
c2 = copyobj(f2_children,fh_new);

if ~isempty(f1_tbox)
    c1 = [c1; tb_new1(:)];
end

if ~isempty(f2_tbox)
    c2  = [c2; tb_new2(:)];
end

%Setup for Left Right merge
if LRdir
    for i=1:length(c1)
        C=c1(i);
        
        C.FontSize=C.FontSize*textshrink;
        
        if isprop(C, 'Position')
            set(C,'units','normalized');
            C.Position(1)=C.Position(1)*ratio;
            C.Position(3)=C.Position(3)*ratio;
        else
            delete(C)
        end
    end
    
    for i=1:length(c2)
        C=c2(i);
        
        C.FontSize=C.FontSize*textshrink;
        
        if isprop(C, 'Position')
            set(C,'units','normalized');
            C.Position(1)=C.Position(1)*(1-ratio);
            C.Position(3)=C.Position(3)*(1-ratio);
            C.Position(1)=C.Position(1)+ratio;
        else
            delete(C)
        end
    end
    
else %Setup for Up Down merge
    for i=1:length(c1)
        C=c1(i);
        
        C.FontSize=C.FontSize*textshrink;
        
        if isprop(C, 'Position')
            set(C,'units','normalized');
            C.Position(2)=C.Position(2)*ratio;
            C.Position(4)=C.Position(4)*ratio;
        else
            delete(C)
        end
    end
    
    for i=1:length(c2)
        C=c2(i);
        
        C.FontSize=C.FontSize*textshrink;
        
        if isprop(C, 'Position')
            set(C,'units','normalized');
            C.Position(2)=C.Position(2)*(1-ratio);
            C.Position(4)=C.Position(4)*(1-ratio);
            C.Position(2)=C.Position(2)+ratio;
        else
            delete(C)
        end
    end
end