function varargout=about_SIRHEN(src,varargin)

mode='window';
rootfig=ancestor(src,'figure');             

name='SIRHEN (Sandia InfraRed HEtrodyne aNalysis)';
%codever='0.4';
%releasedate='December 2010';
codever='0.5 [beta]';
%releasedate='July 2012';
releasedate='August 2013';
switch mode
    case 'name'
        varargout{1}=name;
        varargout{2}=codever;
        varargout{3}=releasedate;
    otherwise
        % generate window
        tag='SIRHEN_AboutScreen';
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
        %load SandiaLogo.mat
        [pathname,filename]=fileparts(mfilename('fullpath'));
        filename=fullfile(pathname,'SandiaLogo.tiff');
        SandiaLogo=imread(filename);
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
        %hc=custom_uicontrol(fig,'Style','text');        
        hc=uicontrol(fig,'Style','text');
        set(hc,'Units','pixels','Position',pos);
        message={};
        message{end+1}='SIRHEN reduces PDV signal to velocity history.';
        message{end+1}='';
        message{end+1}=sprintf('version %s (%s)',codever,releasedate);
        message{end+1}='created by Tommy Ao and Daniel Dolan';
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
        figpos(4)=pos(4)+10;        
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