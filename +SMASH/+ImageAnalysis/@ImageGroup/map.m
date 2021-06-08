%MAP Map ImageGroup coordinate to a new representation
%
% This method applies a mapping function to one or both coordinate
% arrays in ImageGroup object.  It is intended for advanced users only.
% For simple transformations, use the shift and scale methods.  Many data
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
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

% Note: as of making this, the Image function will work on ImageGroups
% directly without this.
function object=map(object,coordinate,method,argument)

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=map(temp{n},coordinate,method,argument);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

