% mend Remove NaN data from a Signal object
%
% This function removes NaN data in a Signal object.  
%    object=mend(object);
% NaN values bracketed by standard entries are replaced by linear
% interpolation; NaN entries that extent to the grid boundary are replaced
% with the first numeric value.
%
% NOTE: this method requires the Data property contain at least one numeric
% value!
%
% See also Signal, merge
%

%
% created January 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%

function object=mend(object)

% locate NaN values
index=isnan(object.Data); % NaN locations
assert(sum(index)<numel(index),'ERROR: no numeric values found');
N=numel(index);

% deal with boundaries
indexbar=~index;
if index(1)    
    start=find(indexbar,1,'first');
    value=object.Data(start);
    k=1:(start-1);
    object.Data(k)=value;
    index(k)=false;
    indexbar(k)=true;
end

if index(end)
    start=find(indexbar(N:-1:1),1,'first')-1;
    start=N-start;
    value=object.Data(start);
    k=(start+1):N;
    object.Data(k)=value;
    index(k)=false;
    indexbar(k)=true;
end

% deal with everything else
start=1;
while true
   offset=find(index(start:end),1,'first');
   if isempty(offset)
       break
   end
   left=start+offset-1;
   xL=object.Grid(left-1);
   yL=object.Data(left-1);
   start=start+offset;
   offset=find(indexbar(start:end),1,'first');
   right=start+offset-1;
   xR=object.Grid(right);
   yR=object.Data(right);
   k=left:(right-1);
   x=object.Grid(k);
   y=yL+(yR-yL)/(xR-xL)*(x-xL);
   object.Data(k)=y;
   index(k)=false;
   indexbar(k)=true;
end

if any(index)
    warning('SMASH:Signal','Signal object was not completely mended');
end

end