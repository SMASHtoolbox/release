% getHandle Get figure handles
%
% This method returns a list of figure handle objects.
%   list=getHandle(mode);
% Optional input "mode" indicates the type of figures returned in "list".
% The default mode 'standard' looks for figures where the HandleVisibility
% property is set to 'on'.  Alternate calls:
%    list=getHandle('all');
%    list=getHandle('hidden');
% return all figures or only those with HandleVisibility set to
% 'off'/'callback', respectively.  The output "list" is sorted so that
% numbered figures appear sequentially at the beginning.
% 
% See also SMASH.Graphics.FigureTools
%
function list=getHandle(mode)

% manage input
if (nargin < 1) || isempty(mode) || strcmpi(mode,'standard')
    list=findobj(groot(),'Type','figure');
elseif strcmpi(mode,'all')
    list=findall(groot(),'Type','figure');
elseif strcmpi(mode,'hidden')
    list=findall(groot(),'Type','figure',...
        'HandleVisibility','off','-or','HandleVisibility','callback');
else
    error('ERROR: invalid search mode');
end

N=numel(list);
numbered=false(1,N);
for n=1:N
    if strcmp(get(list(n),'IntegerHandle'),'on')
        numbered(n)=true;
    end
end

list1=list(numbered);
list2=list(~numbered);
number=nan(size(list1));
for n=1:numel(list1)
    number(n)=list1(n).Number;
end
[~,index]=sort(number);
list1=list1(index);

list=[list1; list2];

end