% convert Convert Options object to another format
%
% This method converts an Options object to a cell array or structure.
%     >> option=convert(object,'cell');
%     >> option=convert(object,'structure');
% The default format 'cell' is convenient for passing options to function
% as a name/value list.
%     >> [...]=myfunction(...,option{:});
%
% See also Options
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function data=convert(object,format)

if (nargin<2) || isempty(format)
    format='cell';
end
assert(ischar(format),'ERROR: invalid format');

switch lower(format)
    case 'cell'
        N=numel(object.Name);     
        data=cell(1,2*N);
        for k=1:N
            data{2*k-1}=object.Name{k};
            data{2*k}=object.Value{k};
        end
    case 'structure'
        data=cell2struct(object.Value,object.Name,2);
        data=orderfields(data);       
end

end