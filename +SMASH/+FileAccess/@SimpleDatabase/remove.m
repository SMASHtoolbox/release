% remove Remove record(s) from the database file
%
% This method removes records from an exisiting database file.%
%    >> remove(object,number);
% Records are specified by a single number or an array of numbers.
%
% See also SimpleDatabase, sort, view
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function remove(object,varargin)

% handle input
if numel(varargin)==1 && isnumeric(varargin{1})
    target=varargin{1};
end

data=read(object);
data(target)=[];
write(object,data);

end