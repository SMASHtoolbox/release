% SMASHtoolbox Interactive toolbox front end
%
% This function provides an interactive front end for the SMASH toolbox.
%    SMASHtoolbox();
% A new dialog shows the toolbox logo and current version number.  Programs
% and other features are available through the menus of that dialog.
%
% The dialog box can be suppressed with an input argument:
%    SMASHtoolbox -version
%    report=SMASHtoolbox('-version');
% printing information in the command window or returning a structure,
% respectively.
%
% See also loadSMASH, smashroot
%
function varargout=SMASHtoolbox(varargin)

% manage input
if nargin == 0
    createGUI();   
elseif strcmpi(varargin{1},'-version')
    if nargout == 0
        aboutSMASH();
    else
      varargout{1}=aboutSMASH();
    end
end

end

%%
function varargout=aboutSMASH(varargin)

location=mfilename('fullpath');
[location,~]=fileparts(location);

% current version number
target=fullfile(location,'SMASHversion');
if exist(target,'file') % release version
    fid=fopen(target,'r');
    data.VersionNumber=fscanf(fid,'%s');
    fclose(fid);
else
    data.VersionNumber='1.1'; % developer version
end

% latest revision date
target=fullfile(location,'*.git');
target=dir(target);
if numel(target)==1
    data.Committed=target.date;
else
    data.Committed='unknown';
end

% handle output
if nargout == 0    
    fprintf('\n');
    fprintf('SMASH toolbox information:\n');
    format='%10s : %s\n';
    fprintf(format,'version',data.VersionNumber);
    fprintf(format,'committed',data.Committed);
    file=fullfile(location,'LICENSE.txt');
    fid=fopen(file,'r');
    while ~feof(fid)
        temp=strtrim(fgets(fid));
        if isempty(temp)
            continue
        end
        fprintf('\n%s\n\n',temp);
        break
    end
    fclose(fid);
    SMASH.System.DocLink('SMASHtoolbox','Toolbox documentation');
else
    varargout{1}=data;
end

end

%%
function createGUI()

location=fileparts(mfilename('fullpath'));
data=SMASHtoolbox('-version');

% see if GUI already exists
fig=findall(groot,'Type','figure','Tag','SMASHtoolbox');
if isgraphics(fig)
    figure(fig);
    return
end

% create GUI
file=fullfile(location,'misc','SMASHlogo.jpg');
logo=imread(file);
LA=size(logo);

pos=get(groot,'ScreenSize');
LB=0.75*repmat(min(pos(3:4)),[1 2]);
if LA(1) > LA(2)
    LB(2)=LB(2)*LA(2)/LA(1);
else
    LB(1)=LB(1)*LA(1)/LA(2);
end
fig=figure('Tag','SMASHtoolbox','Visible','off','Color','w',...
    'NumberTitle','off','Name','SMASH toolbox',...
    'MenuBar','none','Toolbar','none','DockControls','off',...
    'Units','pixels','Position',[0 0 LB(2) LB(1)],...
    'HandleVisibility','callback','IntegerHandle','off');
ha=axes(fig);
imagesc(ha,logo);
axis(ha,'image');
axis(ha,'off');

label{1}=sprintf('Version %s',data.VersionNumber);
label{2}=sprintf('Last updated %s',data.Committed);
scale=SMASH.Graphics.DisplayTools.checkDisplay();
for n=1:numel(scale)
    if scale(n).Spawn
        scale=scale(n);
        break
    end
end
scale=scale.ActualResolution/scale.SetResolution;
title(ha,label,'FontSize',12*scale,'FontWeight','normal');

figure(fig);
movegui(fig,'center');

% menus
hm=uimenu(fig,'Label','Programs');
list=dir(fullfile(location,'programs'));
for n=1:numel(list)
    if list(n).name(1) == '.'
        continue
    elseif ~list(n).isdir
        continue
    end
    uimenu(hm,'Label',list(n).name,'Callback',@runProgram);
end
    function runProgram(src,varargin)
        name=get(src,'Label');
        loadSMASH('-silent','-program',name);
        feval(name);
    end

hm=uimenu(fig,'Label','Apps');
list=dir(fullfile(location,'apps'));
for n=1:numel(list)
    if list(n).name(1) == '.'
        continue
    elseif ~list(n).isdir
        continue
    end
    uimenu(hm,'Label',list(n).name,'Callback',@runApp);
end
    function runApp(src,varargin)
        name=get(src,'Label');
        loadSMASH('-silent','-app',name);
        feval(name);
    end


hm=uimenu(fig,'Label','Tools');
uimenu(hm,'Label','Scale fonts','Callback',@scaleFonts);
    function scaleFonts(varargin)
        SMASH.Graphics.scaleFonts();
    end
uimenu(hm,'Label','Fix documentation','Callback',@fixDoc);
    function fixDoc(varargin)
        SMASH.System.fixDoc();
    end

hm=uimenu(fig,'Label','Examples','Visible','off');
list=dir(fullfile(location,'examples'));
for n=1:numel(list)
    if list(n).name(1) == '.'
        continue
    elseif ~list(n).isdir
        continue
    end
    uimenu(hm,'Label',list(n).name,'Callback',@loadExample);
end
uimenu(hm,'Label','All examples','Callback',@loadExample,'Separator','on');
    function loadExample(src,varargin)
        new=fullfile(pwd,'examples');
        if exist(new,'dir')
            choice=questdlg('Overwrite local examples directory?',...
                'Overwrite','Yes','No','No');
            if ~strcmpi(choice,'yes')
                return
            end
        end
        name=get(src,'Label');
        if strcmpi(name,'All examples')
            name='*';                   
        end        
        loadSMASH('-silent','-example',name);
        if name == '*'
            cd(fullfile(pwd,'examples'));
        else
            cd(fullfile(pwd,'examples',name));
        end
    end

hm=uimenu(fig,'Label','Help');
uimenu(hm,'Label','Command window help','Callback',@showHelp);
    function showHelp(varargin)
        help('SMASHtoolbox');
        commandwindow();
    end
uimenu(hm,'Label','Online documentation','Callback',@showDoc);
    function showDoc(varargin)
        doc('SMASHtoolbox');
    end
uimenu(hm,'Label','Show readme.md','Callback',@showReadme)
    function showReadme(varargin)
        name=fullfile(smashroot,'readme.md');
        web(name);
    end
uimenu(hm,'Label','Release notes','Callback',@showReleaseNotes)
    function showReleaseNotes(varargin)
        name=fullfile(smashroot,'notes','ReleaseNotes.txt');
        web(name);
    end
end
