function HelpWindow(src,varargin)

% get handles
srcfig=ancestor(src,'figure');
srcunits=get(srcfig,'Units');
set(srcfig,'Units','pixels');
srcpos=get(srcfig,'Position');
set(srcfig,'Units',srcunits);

% help message
message={};
message{end+1}='';
message{end+1}='Follow these steps to use the program:';
message{end+1}='';
message{end+1}='Selection Screen:';
message{end+1}='1. Load signal history from a file (Data->Load signal)';
message{end+1}='2. Shift signal along time axis (Data->Shift signal)'; 
message{end+1}='3. Set reference time region (Data->Reference region)'; 
message{end+1}='4. Set experiment time region (Data->Experiment region)';
message{end+1}='5. Optional adjustment of parameters (Options->General,STFT,Display)';
message{end+1}='6. Click Next button to switch to Analysis Screen';
message{end+1}='';
message{end+1}='Analysis Screen:';
message{end+1}='1. Adjust calculation of velocity history (Data->Calculate history)';
message{end+1}='2. Export velocity history (Data->Export history)';
message{end+1}='3. Export image of STFT spectrum (Data->Export STFT image)';
message{end+1}='4. Optional adjustment of parameters (Options->General,STFT,Display)';
message{end+1}='5. Click Previous to switch to Selection Screen';
message{end+1}='';


% create help window
tag='SIRHEN_HelpWindow';
fig=findall(0,'Type','figure','Tag',tag);
if ~isempty(fig) % figure already exists
    delete(fig);
end
fig=figure('Visible','off','Menubar','none','Toolbar','none',...
    'Tag',tag,'NumberTitle','off','Name','Using SIRHEN',...
    'IntegerHandle','off','HandleVisibility','Callback',...
    'Units','pixels');

htext=uicontrol(fig,'Style','text','String',message,'Units','pixels',...
    'HorizontalAlignment','left');
%[message,position]=textwrap(htext,message);
extent=get(htext,'Extent');
%set(htext,'String',message,'Position',position);
%set(htext,'Units','pixels');
%position=get(htext,'Position');
%position(1:2)=5;
margin=5;
position=[margin margin extent(3)+margin extent(4)+margin];
set(htext,'Position',position,'BackgroundColor',get(fig,'Color'));

figpos=get(fig,'Position');
figpos(3)=position(3)+2*position(1);
figpos(4)=position(4)+2*position(2);
figpos(1)=srcpos(1)+(srcpos(3)-figpos(3))/2;
figpos(2)=srcpos(2)+(srcpos(4)-figpos(4))/2;
set(fig,'Position',figpos,'Visible','on');