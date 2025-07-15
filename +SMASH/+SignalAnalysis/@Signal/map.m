% MAP Map object coordinate(s) to a new representation
%
% This method allows applies a mapping function to the Grid or Data array
% in Signal object.  It is intended for advanced users only.  For simple
% Grid transformations, use the shift and scale methods.  Data
% transformations can often be performed directly.
%    >> object=2*object+1; % multiply Data by 2 and add 1
% 
% If the above solutions are insufficient, this method should be called
% with the following syntax.
%    >> object=map(object,coordinate,method,argument);
% The "coordinate" shoulbe be 'Grid' or 'Data'.  Three mapping
% methods--'polynomial','table', and 'custom'--are supported.  The final
% input depends on the method. Polynomial mapping requires a N+1 length for
% a N-th order polynomial. Table mapping requires two-column table of input
% and output values used for interpolation.  Custom mapping requires a
% handle to a function that accepts and returns a single array; note that
% this array may have one or two columns, dpending on the coordinate
% choice.
%
% See also Signal, shift, scale
%

%
% created December 2, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=map(object,coordinate,method,argument)

% handle input
if nargin<4
    error('ERROR: insufficient number of inputs');
end

% perform mapping
switch lower(coordinate)
    case {'grid'}
        coordinate='Grid';
        data=object.Grid(:);
    case {'data'}
        coordinate='Data';
        data=object.Data(:);
    %case 'all'
    %    data=[object.Grid(:) object.Data(:)];
    otherwise
        error('ERROR: %s is an invalid coordinate choice');
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

switch coordinate
    case 'Grid'
        object.Grid=reshape(data,size(object.Grid));
    case 'Data'
        object.Data=reshape(data,size(object.Data));
    %case 'all'
    %    object.Grid=reshape(data(:,1),size(object.Grid));
    %    object.Data=reshape(data(:,2),size(object.Data));
end

object=verifyGrid(object);
object=updateHistory(object);

end