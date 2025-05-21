% MAP Map object coordinate(s) to a new representation
%
% This method allows applies a mapping function to the Grid or Data array
% in SignalGroup object.  It is intended for advanced users only.  For simple
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
% See also SignalGroup, shift, scale
%

%
% created November 20, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=map(object,varargin)

temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,1));
temp=map(temp,varargin{:});
if strcmpi(varargin{1},'Grid')
    object.Grid=temp.Grid;
else
    object.Data(:,1)=temp.Data;
    for n=2:object.NumberSignals
        temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
        temp=map(temp,varargin{:});
        object.Data(:,n)=temp.Data;
    end
end        

object=updateHistory(object);

end