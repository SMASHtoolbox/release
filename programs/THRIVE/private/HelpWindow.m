function HelpWindow(src,varargin)

% get handles
srcfig=ancestor(src,'figure');
srctag=get(srcfig,'Tag');
srcpos=get(srcfig,'Position');

message={};
switch srctag
    case 'THRIVE_LoadScreen'
        name='Loading data';
        message{end+1}='Loading data into THRIVE:';
        message{end+1}='';
        message{end+1}='1. Specify data storage method';
        message{end+1}='   -"Single file" means a text file with four numerical columns';
        message{end+1}='   -"Separate files" means three signal files ()';
        message{end+1}='';
        message{end+1}='2. Specify the file name(s)';
        message{end+1}='   -The "select" button launches a file selection dialog';
        message{end+1}='   -Entries may also be typed in the edit box (local path conventions apply)';
        message{end+1}='   -Verify the column order for single file data';
        message{end+1}='   -Press "Load data" to read data into the program';
        message{end+1}='';
        message{end+1}='3. Specify the characterization time range';
        message{end+1}='   -Data in this region is used for ellipse fitting later on';
        message{end+1}='   -Left/right mouse buttons select the start and end of this region';
        message{end+1}='';
        message{end+1}='4. Specify the experiment time range';
        message{end+1}='   -Data in this region undergoes analysis (all other data is ignored)';
        message{end+1}='   -Left/right mouse buttons select the start and end of this region';
        message{end+1}='';
        message{end+1}='5. Press "Next" to continue';
        message{end+1}='   -Next stage depends on the "Characterization" menu setting';
    case 'THRIVE_EllipseScreen'
        name='Ellipse characterization';
        message{end+1}='Ellipse fitting in THRIVE:';
        message{end+1}='';
        message{end+1}='1. Optimize the ellipse parameters';
        message{end+1}='   -Individual parameters can be entered manually';
        message{end+1}='   -"Optimize parameters" varies un-fixed parameters';
        message{end+1}='   -"Guess parameters" varies all parameters simultaneously, resetting fixed values';
        message{end+1}='';
        message{end+1}='2. Interpret the ellipse parameters';
        message{end+1}='   -Scaling ratios R12 and R13 are related to the ellipse fit parameters';
        message{end+1}='   -The ratio values depend on a choice of root sign, which requires an assumption';
        message{end+1}='   -"ref>target" implies that the ellipse contains more reference light that target light (and vice versa)';
        message{end+1}='   -Sign assumptions can be made individually or linked together';
        message{end+1}='   -For AC coupled measurements, the user can specify R12 and R13 directly';
        message{end+1}='';
        message{end+1}='3. Press "Next" to continue to the quadrature signal screen';
    case 'THRIVE_QuadratureScreen'
        name='Quadrature signals';
        message{end+1}='Quadrature signals in THRIVE:';
        message{end+1}='';
        message{end+1}='1. Quadrature characterization';
        message{end+1}='   -Deviations calculated with respect to a perfect circle';
        message{end+1}='   -Horizontal/vertical centering (center/amplitude) should be close to zero)';
        message{end+1}='   -Aspect ratio (horiztonal/vertical) should be near 100%';
        message{end+1}='   -Quadrature error should be near 0 degrees';
        message{end+1}='';
        message{end+1}='2. Vary the display (optional)';
        message{end+1}='   -Data from the characterization or experiment time range can be displayed';
        message{end+1}='   -Quadrature results can be viewed as two signals or in ellipse format';
        message{end+1}='';
        message{end+1}='3. Press "Next" to continue to the results screen';
    case 'THRIVE_ResultsScreen'
        name='Results';
        message{end+1}='THRIVE results:';
        message{end+1}='1. Select interferometer type';
        message{end+1}='   -Choose "Displacement" for PDV configurations';
        message{end+1}='   -Choose "Velocity" for VISAR configurations';
        message{end+1}='';
        message{end+1}='2. Set analysis parameters';
        message{end+1}='   -The fringe constant controls scaling between the fringe shift and position/velocity';
        message{end+1}='   -"Fit order" and "# points" control Savitzky-Golay smoothing/differentiation of the fringe shift';
        message{end+1}='   -Press "Update plot" to apply these analysis parameters';
        message{end+1}='';
        message{end+1}='3. Use the popup menu to display fringe shift, position, or velocity';
        message{end+1}='';
        message{end+1}='4. Export data to a file';
        message{end+1}='   -File name can be entered manually or chosen with the "select" button';
        message{end+1}='   -Output variables are selected in the "Export options" menu';
        message{end+1}='   -Press the "Export button" to save data (no overwrite warnings given)';        
end

% create help window
tag='THRIVE_HelpWindow';
fig=findall(0,'Type','figure','Tag',tag);
if ~isempty(fig) % figure already exists
    delete(fig);
end
fig=figure('Visible','off','Menubar','none','Toolbar','none',...
    'Tag',tag,'NumberTitle','off','Name',name,...
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