% loadSMASH Make toolbox items available to MATLAB
%
% This function makes items from the SMASH toolbox available to MATLAB.
%
% Toolbox programs are added to the MATLAB path.
%      loadSMASH -program name % specific program
%      loadSMASH -program name1 name2 % multiple programs
%      loadSMASH -program * % all programs
% Programs can be loaded and called from the command window: 
%      loadSMASH -program SIRHEN % load SIRHEN program onto path
%      SIRHEN % launch SIRHEN program
% or inside functions.  Programs loaded in any workspace are available to
% all workspaces and remain on the MATLAB path throughout the current
% session (unless manually removed).
%
% Toolbox packages are loaded into the current workspace.  Consider the
% FileAccess package:
%    loadSMASH -package FileAccess.readFile % load specific content
%    loadSMASH -package FileAccess.*File    % load content ends in "File"
%    loadSMASH -package FileAccess.*        % load all content
% Package contents include both functions and class definitions.  Requests
% can begin with 'SMASH.' or directly reference the subpackage (as shown
% above). 
%
% By default, this function displays items being added in the command
% window.  This behavior can be controlled with the silent/verbose options.
%      loadSMASH -verbose ... % display items
%      loadSMASH -silent ...  % suppress item display 
%
% See also SMASHtoolbox, packtools
%

% examples being revamped
% Toolbox package examples can be copied to the current directory.
%      loadSMASH -example name % specific package examples
%      loadSMASH -example * % all examples
% Examples should be copied from the toolbox before execution or editing!
%

%

%
% created January 13, 2015 by Daniel Dolan (Sandia National Laboratories)
% updatd October 20, 2017 by Daniel Dolan
%    -Packages are now loaded using function handles (packtools class)
%
function varargout=loadSMASH(varargin)

% manage input
if nargin == 0
    location=fileparts(mfilename('fullpath'));
    data=SMASHtoolbox('-version');
    createGUI(location,data);
    return
end

verbose=true;
mode='';
name={};
while numel(varargin)>0
    switch varargin{1}
        case '-verbose'
            verbose=true;
            varargin=varargin(2:end);
        case '-silent'
            verbose=false;
            varargin=varargin(2:end);
        case {'-program','-programs','-package','-packages'}
            assert(isempty(mode),'ERROR: mode conflict detected');
            mode=varargin{1};
            varargin=varargin(2:end);
            while numel(varargin)>0
                if varargin{1}(1)=='='
                    break
                end
                name{end+1}=varargin{1}; %#ok<AGROW>
                varargin=varargin(2:end);
            end             
        otherwise
            error('ERROR: invalid input detected');
    end
end
assert(~isempty(mode),'ERROR: no mode specified');
assert(~isempty(name),'ERROR: no names specified');

% load named directories
switch mode
    case {'-program' '-programs'}
        loadProgram(name,verbose);
        if nargout > 0
            varargout{1}=name;
        end
    case {'-package' 'packages'}
        for m=1:numel(name)
            if strcmp(name{m}(1:6),'SMASH.')
                request=name{m};
            else
                request=sprintf('SMASH.%s',name{m});
            end
            try
                [local,package]=packtools.import(request);
            catch
                error('ERROR: invalid package name "%s"',name{m});
            end
            content=fieldnames(local);
            if isempty(content)
                message=cell(3,1);
                message{1}=sprintf('ERROR: content not found in package %s',package);
                message{2}='       Verify spelling for a specific package function or class';                
                message{3}='       Use .* to request all functions and classes';
                error('%s\n',message{:});
            end
            if nargout == 0
                for n=1:numel(content)
                    assignin('caller',content{n},local.(content{n}));
                    if verbose
                        fprintf('Loading %s from %s package\n',content{n},package);
                    end
                end
            else
                varargout{1}=local;
            end
        end                            
end

end

%%
function loadProgram(name,verbose)

% look at program directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'programs');
list=scanDirectory(local);

% load requested program(s)
if (numel(name)==1) && strcmp(name{1},'*')
    name=list;
end

N=numel(name);
for k=1:N
    test=cellfun(@(x) strcmp(x,name{k}),list);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:program',...
            'Program %s not found in SMASH toolbox',name{k});
    elseif strcmpi(name{k},'development')
        continue % skip development directory
    else
        addpath(fullfile(local,name{k}));
        if verbose
            fprintf('Adding %s to the MATLAB path\n',name{k});
        end
    end
end

end

%% utility function
function list=scanDirectory(dirname,mode)

if (nargin<2) || isempty(mode)
    mode='standard';
end

list={};
filename=dir(dirname);
for k=1:numel(filename)
    if ~filename(k).isdir % non-directory
        continue
    elseif filename(k).name(1)=='.' % hidden directory
        continue
    elseif strcmp(mode,'standard') && (filename(k).name(1) ~='+') % package directory
        list{end+1}=filename(k).name; %#ok<AGROW>
    elseif strcmp(mode,'package')  && (filename(k).name(1) =='+') % standard directory
        list{end+1}=filename(k).name(2:end); %#ok<AGROW>
    end
end

end

%%
function createGUI(location,data)

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