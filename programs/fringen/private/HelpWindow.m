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
message{end+1}='1. Load velocity history from a file ("Program" menu)';
message{end+1}='  -Select "Load Data" to choose a velocity history.';
message{end+1}='  -The data file must contain at least two columns [time velocity].';
message{end+1}='  -Additional columns (optional) specify the coherent, emitted, and reference intensity.';
message{end+1}='     [time velocity Icoherent Iemitted Ireference]';
message{end+1}='     Icoherent defaults to unity, Iemitted defaults to zero';
message{end+1}='     Ireference defaults to unity (used PDV mode only)';

message{end+1}='';
message{end+1}='2. Specify the interferometer mode and parameters ("Interferometer" menu)';
message{end+1}='   -Interferometer mode may be VISAR (default) or PDV.';
message{end+1}='   -Select "Parameters" to specify general and mode specific parameters.';
message{end+1}='   -The "Phase shift(s) entry determines the number of calculated signals.';
message{end+1}='   -Scaling parameters are replicated as needed. ';

message{end+1}='';
message{end+1}='3. Add signal imperfections ("Signal" menu)';
message{end+1}='   -Signal coupling may be DC (default) or AC';
message{end+1}='      AC coupling forces signal average(s) to zero for t<0.';
message{end+1}='      If no t<0 data exists, the first point is subtracted from the entire signal.';
message{end+1}='   -Specify impulse response function to include frequency-dependence';
message{end+1}='      Information should be stored in a two-column text file.';
message{end+1}='   -Use "Noise parameters" to add Gaussian noise.';
message{end+1}='      Noise fraction sets rms amplitude relative to signal.';
message{end+1}='      Noise seed creates a reproducible noise pattern.';
message{end+1}='   -Use "Digitizer parameters" to specify bit range.';

message{end+1}='';
message{end+1}='4. Moving on ("Program" menu)';
message{end+1}='   -Select "Export results" to save caculated signals to a file.';
message{end+1}='   -Select "Start over" to clear all settings and restore default state.';
message{end+1}='';

% create help window
tag='fringen_HelpWindow';
fig=findall(0,'Type','figure','Tag',tag);
if ~isempty(fig) % figure already exists
    delete(fig);
end
fig=figure('Visible','off','Menubar','none','Toolbar','none',...
    'Tag',tag,'NumberTitle','off','Name','Using fringen',...
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