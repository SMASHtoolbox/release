% THRIVE : Three-interferometer velocity analysis program
%
% Type "THRIVE" to launch the program or make it active.
%
% version 1.0 released May 2008

% created by Daniel Dolan
% version control
function THRIVE()

% see if program is already running
basetag='THRIVE_';
Nbase=numel(basetag);
openfig=allchild(0);
for ii=1:numel(openfig)
    tag=get(openfig(ii),'Tag');
    visible=get(openfig(ii),'Visible');
    if strncmp(tag,basetag,Nbase) && strcmp(visible,'on');
        fprintf('Program is already running!\n');
        figure(openfig(ii));
        return
    end
end

% create figures
hwait=waitbar(0,'Launching THRIVE...please wait',...
    'Name','Launching THRIVE');
fig=[];
fig(end+1)=LoadScreen;
waitbar(1/4,hwait);
fig(end+1)=QuadratureScreen;
waitbar(2/4,hwait);
fig(end+1)=EllipseScreen;
waitbar(3/4,hwait);
fig(end+1)=ResultsScreen;
waitbar(4/4,hwait);
set(fig,'HandleVisibility','callback','CloseRequestFcn',@exitTHRIVE);

% store function handle
old=pwd;
pathname=mfilename('fullpath');
[pathname,filename]=fileparts(pathname);
cd(pathname);
data.fhandle=@THRIVE;
cd(old);
hmenu=findall(fig,'Type','uimenu','Tag','StartOver');
set(hmenu,'UserData',data);

delete(hwait);
figure(fig(1));

%%%%%%%%%%%%%%%%%
% exit strategy %
%%%%%%%%%%%%%%%%%
function exitTHRIVE(varargin)

button=questdlg('Are you sure you want to exit?','Exit THRIVE?','No');
if strcmpi(button,'yes')
    %setting={};
    basetag='THRIVE_';
    Nbase=numel(basetag);
    fig=allchild(0);
    for ii=1:numel(fig)
        tag=get(fig(ii),'Tag');
        if strncmp(tag,basetag,Nbase)
            %handle=findall(fig(ii),'Type','uicontrol','-or','Type','uimenu');
            %for n=1:numel(handle)
            %    if isempty(get(handle(n),'Tag'))
            %        continue
            %    end
            %    temp=get(handle(n));
            %    temp.figtag=tag;
            %    setting{end+1}=temp;
            %end
            delete(fig(ii));
        end
    end
end