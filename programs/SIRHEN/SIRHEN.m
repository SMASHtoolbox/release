% SIRHEN: Sandia InfraRed HEterodyNe analysis program
function varargout=SIRHEN(varargin)

if isdeployed
    varargout{1}=true;
end

% see if program is already running
basetag='SIRHEN';
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
hwait=waitbar(0,'Launching SIRHEN...please wait',...
    'Name','Launching SIRHEN');
fig=[];
fig(end+1)=SelectionScreen;
waitbar(1/2,hwait);
fig(end+1)=AnalysisScreen;
waitbar(2/2,hwait);
set(fig,'HandleVisibility','callback','CloseRequestFcn',@exitSIRHEN);
set(fig,'Visible','off');
figure(fig(1));

% store admin data
data=get(fig(1),'UserData');
N=numel(fig);
data.handle=cell(1,N);
for n=1:N
    data.handle{n}=guihandles(fig(n));
end
data.update.signal=false;
data.update.fullSTFT=false;
data.update.ref_frequency=false;
data.update.experimentSTFT=false;
data.update.history=false;
set(fig,'UserData',data);

% store function handle
old=pwd;
pathname=mfilename('fullpath');
[pathname,filename]=fileparts(pathname);
cd(pathname);
data.fhandle=@SIRHEN;
cd(old);
hmenu=findall(fig,'Type','uimenu','Tag','StartOver');
set(hmenu,'UserData',data);

delete(hwait);
figure(fig(1));

%%%%%%%%%%%%%%%%%
% exit strategy %
%%%%%%%%%%%%%%%%%
function exitSIRHEN(varargin)

button=questdlg('Are you sure you want to exit?','Exit SIRHEN?','No');
if strcmpi(button,'yes')
    %setting={};
    basetag='SIRHEN_';
    Nbase=numel(basetag);
    fig=allchild(0);
    for ii=1:numel(fig)
        tag=get(fig(ii),'Tag');
        if strncmp(tag,basetag,Nbase)
            delete(fig(ii));
        end
    end
end