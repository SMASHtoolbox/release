% MAP Map Image object coordinate(s) to a new representation
%
% This method allows applies a mapping function to one or both coordinate
% arrays in Image object.  It is intended for advanced users only.  For
% simple transformations, use the shift and scale methods.  Many data
% transformations can be performed directly.
%    >> object=2*object+1; % Data is multipied by 2 and added by one
% 
% If the above solutions are insufficient, this method should be called
% with the following syntax.
%    >> object=map(object,coordinate,method,argument);
%
% Valid coordinate choices are 'Grid1', 'Grid2', and 'Data'.  Three mapping
% methods--'polynomial','table', and 'custom'--are supported.  The final
% input depends on the method. Polynomial mapping requires a N+1 length for
% a N-th order polynomial. Table mapping requires two-column table of input
% and output values used for interpolation.  Custom mapping requires a
% handle to a function that accepts and returns a single array; note that
% this array may have one or two columns, depending on the coordinate
% choice.
%
% See also IMAGE, scale, shift

% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=map(object,coordinate,method,argument)

% handle input
if nargin<4
    error('ERROR: insufficient number of inputs');
end

% perform mapping
switch lower(coordinate)
    case {'grid1'}
        data=object.Grid1(:);
    case {'grid2'}
        data=object.Grid2(:);
    case {'data'}
        data=object.Data(:);
    otherwise
        error('ERROR: %s is an invalid coordinate choice',coordinate);
end

switch lower(method)
    case 'polynomial'
        if ~isnumeric(argument) || numel(argument)<2
            error('ERROR: invalid argument for polynomial mapping');
        end
        temp=polyval(argument,data(:));
        data=reshape(temp,size(data));
    case 'table'
        if ~isnumeric(argument) || (size(argument,2)~=2) || (size(argument,1)<2)
            error('ERROR: invalid argument for lookup table mapping');
        end
        argument=sortrows(argument,1);
        temp=interp1(argument(:,1),argument(:,2),data(:),'linear');
        data=reshape(temp,size(data));
    case 'custom'
        if ~isa(argument,'function_handle')
            error('ERROR: invalid argment for user-function mapping');
        end
        temp=feval(argument,data);
        if any(size(temp)~=size(data))
            error('ERROR: mapping function must preserve array size');
        end
        data=temp;
    otherwise
        error('ERROR: %s is an invalid method');
end

switch lower(coordinate)
    case 'grid1'
        object.Grid1=reshape(data,size(object.Grid1));
    case 'grid2'
        object.Grid2=reshape(data,size(object.Grid2));
    case 'data'
        object.Data=reshape(data,size(object.Data));
end

object=verifyGrid(object);
object=updateHistory(object);

end