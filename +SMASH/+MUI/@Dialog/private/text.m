function varargout=text(object,label,minwidth)

% handle input
if (nargin<2)
    label='Label ';
end

if ischar(label)
    label={label};
else
    for n=1:numel(label)
        if isempty(label{n})
            label{n}='';
        end
    end
    if isstring(label)
        label=cellstr(label);
    end
    assert(iscellstr(label),'ERROR: invalid label'); %#ok<ISCLSTR>
end

if (nargin<3) 
    minwidth=cellfun(@numel,label);
    minwidth=max(minwidth);   
end

% error checking
verify(object);

% create text block
N=numel(label);
dummy=cell(N,1);
width=0;
for n=1:N
    dummy{n}=repmat('M',[1 minwidth]);    
    if isempty(minwidth) || (minwidth(1)==0)
       dummy{n}=label{n};
    end
%     else
%        dummy{n}=repmat('M',[1 numel(label{n})]);
%     end
    width=max([width numel(dummy{n})]);
end

h=local_uicontrol(object,'Style','text','String',dummy,...
    'HorizontalAlignment','left');
h.Position(3)=h.Extent(3);
set(h,'String',label);
pushup(object);
pushup(object,1,object.VerticalGap);
make_room(object);

object.Controls(end+1)=h;

% handle output
if nargout>0
    varargout{1}=h;
    varargout{2}=width;
end

end