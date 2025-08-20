% PeriodicTable Access data from the periodic table
%
% This function provides element data from the periodic table.  
% Numeric input:
%   entry=PeriodicTable(number);
% looks up an element by atomic number.  Character input:
%   entry=PeriodicTable(symbol);
%   entry=PeriodicTable(name);
% looks up an element by symbol or name; the former is case sensitive but
% the latter is not.  The output "entry" is a structure with fields Symbol,
% Name, Mass, and so forth.
%
% Calling this function with no input:
%    PeriodicTable();
% displays an interactive periodic table.
%
% See also SMASH.Reference
%

%
% created February 20, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=PeriodicTable(request)

% manage input
if (nargin == 0) || isempty(request)
   browse();
   return
end

% look up requested element
DataTable=lookup([]);
Nelements=numel(DataTable);

if isnumeric(request)
    valid=1:Nelements;
    assert(isscalar(request) && any(request == valid),...
        'ERROR: invalid atomic number');
else
    assert(ischar(request),'ERROR: invalid table request');
    match=false;
    for n=1:Nelements
        if strcmp(request,DataTable(n).Symbol)
            request=n;
            match=true;
            break
        end
    end
    if ~match
        for n=1:Nelements
            if strcmpi(request,DataTable(n).Name)
                request=n;
                match=true;
                break
            end
        end
        assert(match,'ERROR: invalid symbol/name');            
    end    
end

varargout{1}=lookup(request);

end

%%
function data=lookup(number)

persistent DataTable 
if isempty(DataTable)
    file=fileparts(mfilename('fullpath'));
    file=fullfile(file,'data','PeriodicTable.json');
    fid=fopen(file,'r');
    temp=fscanf(fid,'%c');
    fclose(fid);
    DataTable=jsondecode(temp);
end

% return data
if isempty(number)
    data=DataTable;
else
    data=DataTable(number);
end
%data.Link=sprintf('<a href = "%s">%s</a>',data.Reference,data.Reference);

end

%%
function browse(varargin)

DataTable=lookup([]);
block=cell(size(DataTable));
for k=1:numel(block)
    block{k}=DataTable(k).Block;
end
block=unique(block);
BlockColor=ones(numel(block),3);
%BlockColor(1,:)=[0 1 1];
%BlockColor(5,:)=[1 0 1];

%
db=SMASH.MUI.Dialog('FontSize',12);
%db.Hidden=true;
db.Name='Periodic table';

hAxes=addblock(db,'medit','Select element:',80,30);
hProperties=addblock(db,'medit','Properties of X:',50,10);
set(hProperties(1),'FontWeight','bold');
set(hProperties(2),'Callback',@undoTyping);
    function undoTyping(src,varargin)
        set(src,'String',get(src,'UserData'));
    end

pos=getpixelposition(hAxes(2));
delete(hAxes);
hAxes=axes('Parent',db.Handle,'YDir','reverse');
setpixelposition(hAxes,pos);
number=0;
pos=[-0.5 -0.5 1 1];
for m=1:9
    pos(1)=-0.5;
    pos(2)=pos(2)+1;
    for n=1:18    
        pos(1)=pos(1)+1;
        switch m
            case 1
                if ~any(n == [1 18])
                    continue
                end
            case 2 
                if ~any(n == [1 2 13:18])
                    continue
                end
            case 3
                if ~any(n == [1 2 13:18])
                    continue
                end
            case 4
                % do nothing
            case 5
                % do nothing
            case 6                
                if any(n == 3)
                    number=71;
                    continue
                end
            case 7
                if any(n == 3)
                    number=103;
                    continue
                end
            case 8
                if n == 1                    
                    pos(2)=pos(2)+0.5;
                end
                if n == 2
                    number=56;
                end                  
                if ~any(n == 3:17)
                    continue
                end
            case 9
                if n == 2
                    number=88;
                end
                if ~any(n == 3:17)
                    continue
                end
        end
        number=number+1;
        for jj=1:numel(block)
            if strcmp(DataTable(number).Block,block{jj})
                color=BlockColor(jj,:);
                break
            end
        end
        rectangle('Parent',hAxes,'Position',pos,'FaceColor',color,...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number));
        
        switch lower(DataTable(number).StandardPhase)
            case 'solid'
                FontColor='k';
            case 'liquid'
                FontColor='b';
            case 'gas'
                FontColor='r';
        end        
        text('Parent',hAxes,'Position',pos(1:2)+pos(3:4)/2,...
            'String',DataTable(number).Symbol,'FontSize',18,...
            'Color',FontColor,'HorizontalAlignment','center',...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number))
        text('Parent',hAxes,'Position',[pos(1)+0.05*pos(3) pos(2)+0.05*pos(4)],...
            'String',sprintf('%d',number),'FontSize',10,...
            'HorizontalAlignment','left','VerticalAlignment','top',...
            'ButtonDownFcn',@selectElement,'UserData',DataTable(number))
    end
end
axis(hAxes,'tight');
axis(hAxes,'off');
hBlock=findobj(hAxes,'Type','rectangle'); hBlock=hBlock(end:-1:1);
    function selectElement(src,varargin)
        data=get(src,'UserData');
        number=data.Number;
        for kk=1:numel(hBlock)
            temp=get(hBlock(kk),'UserData');
            if temp.Number == number
                set(hBlock(kk),'FaceColor','y');
            else
                set(hBlock(kk),'FaceColor','w');
            end
        end        
        label=sprintf('Properties of %s (%s)',data.Symbol,data.Name);
        set(hProperties(1),'String',label);
        label={};
        label{end+1}=sprintf('Atomic number: %g',data.Number);
        label{end+1}=sprintf('Atomic mass: %g',data.Mass);
        label{end+1}=sprintf('Series: %s',data.Block);
        label{end+1}=sprintf('Standard density: %g g/cc (%s)',...
            data.StandardDensity,lower(data.StandardPhase));
        label{end+1}=sprintf('Configuration: %s',data.Configuration);
        label{end+1}=sprintf('Melting point: %g K',data.Melt);
        label{end+1}=sprintf('Boiling point: %g K',data.Boil);
        set(hProperties(2),'String',label,'UserData',label);
    end

selectElement(hBlock(1));

set(db.Handle,'HandleVisibility','callback');
locate(db,'center');
show(db);

end