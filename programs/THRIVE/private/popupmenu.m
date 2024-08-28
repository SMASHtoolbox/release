function [h,pos]=popupmenu(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

%extra=repmat('M',[1 5]);
[maxchar,kmax]=max(cellfun(@numel,string));
maxchar=max([maxchar 10]);
%teststring=[string{kmax} extra];
teststring=repmat('M',[1 maxchar]);
[h,posA]=custom_uicontrol('Parent',parent,...
    'Style','text','string',teststring);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});
set(h,'Style','popupmenu','String',string);

%get(h,'BackgroundColor');
%set(h,'BackgroundColor',[1 1 1]);
if ispc
    bgcolor=[1 1 1];
end
if ismac
    switch lower(get(parent,'Type'))
        case 'figure'
            bgcolor=get(parent,'Color');
        otherwise
            bgcolor=get(parent,'BackgroundColor');
    end
end
set(h,'BackgroundColor',bgcolor);