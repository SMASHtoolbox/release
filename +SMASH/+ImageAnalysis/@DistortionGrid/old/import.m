function object=import(object,varargin)

% handle input
assert(nargin>1,'ERROR: insufficient input');

if ischar(varargin{1})
   temp=SMASH.FileAccess.readFile(varargin{1},'column');
   try
   object=import(object,temp);
   catch
       error('ERROR: unable to read two columns from file');
   end
   return  
elseif isnumeric(varargin{1})
    switch numel(varargin)
        case 1
            if size(varargin{1},2)==2
                x=varargin{1}(:,1);
                y=varargin{1}(:,2);
            else
                error('ERROR: invalid input table');
            end
        case 2                        
            if isnumeric(varargin{2}) ...
                    && all(size(varargin{1})==size(varargin{2})) ...
                    && any(varargin{1}==1)                
                x=varargin{1}(:);
                y=varargin{2}(:);
            else
                error('ERROR: invalid input array(s)');
            end
        otherwise
            error('ERROR: invalid input');
    end
else
    error('ERROR: invalid input');
end

% error checking
assert(all(isnan(x)==isnan(y)),'ERROR: group boundary mismatch');

% store results
object.IsoPoints1=x;
object.IsoPoints2=y;

object=createMesh(object);

end