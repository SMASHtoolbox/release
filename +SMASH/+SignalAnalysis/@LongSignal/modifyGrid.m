% modifyGrid Modify signal grid
%
% This method modifies the underlying grid of a LongSignal object.
%    modifyGrid(object,'Shift',value); % add "value" to the grid
%    modifyGrid(object,'Scale',value); % multiply grid by "value"
% Sequential modifications are proccessed in order.
%    modifyGrid(object,'Scale',factor,'Shift',value); % scale, then shift
%    modifyGrid(object,'Shift',value,'Scale',factor); % shift, then scale
%
% See also LongSignal
%

%
% created May 22, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function modifyGrid(object,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');

% modify grid settings
start=object.Start;
stop=object.Stop;
increment=object.Increment;

for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid parameter name');
    value=varargin{n+1};
    switch lower(name)
        case 'shift'
            assert(SMASH.General.testNumber(value),'ERROR: invalid shift');            
            start=start+value;
            stop=stop+value;
        case 'scale'
            assert(SMASH.General.testNumber(value),'ERROR: invalid scale');
            start=value*start;
            stop=value*stop;
            increment=value*increment;
        otherwise
            error('ERROR: "%s" is not a valid parameter name');
    end
end

% save updates
h5writeatt(object.File,'/Signal','GridStart',start);
h5writeatt(object.File,'/Signal','GridStop',stop);
h5writeatt(object.File,'/Signal','GridIncrement',increment);

end