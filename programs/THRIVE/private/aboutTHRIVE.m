function varargout=aboutTHRIVE(varargin)

mode='window';
rootfig=[];
switch nargin
    case 1
        mode=varargin{1};
    case 3
        rootfig=varargin{3};
end               

name='THRIVE (THRee-Interferometer VElocimetry)';
%codever='1.2';
%releasedate='July 2016';
codever='1.3';
releasedate='November 2016';
switch mode
    case 'name'
        varargout{1}=name;
        varargout{2}=codever;
        varargout{3}=releasedate;
    otherwise
        % generate window
        tag='THRIVE_AboutScreen';
        fig=findall(0,'Type','figure','Tag',tag);
        if isempty(fig);
            fig=figure('Name',name,'NumberTitle','off','Resize','off',...
                'Units','pixels','Menubar','none','Toolbar','none',...
                'Tag',tag,'Color',[1 1 1],...
                'IntegerHandle','off','HandleVisibility','Callback');
        else
            figure(fig);
            return
        end        
        % render logo
        load SandiaLogo.mat
        Ly=size(SandiaLogo,1);
        Lx=size(SandiaLogo,2);
        ha=axes('Parent',fig);
        imagesc(SandiaLogo,'Parent',ha);
        axis(ha,'image');
        axis(ha,'off');       
        imsize=[Lx Ly];
        set(ha,'Units','pixels','Position',[0 0 imsize]);
        pos=get(ha,'Position');
        
        % text description
        pos(1)=pos(1)+pos(3);
        pos(3)=2*pos(3);
        hc=custom_uicontrol(fig,'Style','text');        
        set(hc,'Units','pixels','Position',pos);
        message={};
        message{end+1}=[...
            'This program calculates velocity and position data from three-interferometer velocimetry measurements.'];        
        message{end+1}='';
        message{end+1}=sprintf('version %s (%s)',codever,releasedate);
        message{end+1}='created by Daniel Dolan';
        message{end+2}='';
        message=textwrap(hc,message);
        set(hc,'String',message);
        extent=get(hc,'Extent');
        pos(4)=extent(4);
        set(hc,'Position',pos);
        set(hc,'BackgroundColor',get(fig,'Color'));
        
        % size the window
        figpos=get(fig,'Position');
        figpos(3)=pos(1)+pos(3);
        figpos(4)=pos(4);        
        set(fig,'Position',figpos);        
        if ishandle(rootfig)
            units=get(rootfig,'Units');
            set(rootfig,'Units','pixels');
            rootpos=get(rootfig,'Position');
            figpos(1)=rootpos(1)+(rootpos(3)-figpos(3))/2;
            figpos(2)=rootpos(2)+(rootpos(4)-figpos(4))/2;
            set(fig,'Position',figpos,'Units',units);
        end
        
        % reposition the logo
        pos=get(ha,'Position');
        pos(2)=figpos(4)-pos(4);
        set(ha,'Position',pos);
end