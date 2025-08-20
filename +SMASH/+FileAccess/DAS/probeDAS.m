% probeDAS
%
%    >> names=probeDAS(shot,style);
%
% See also readDAS
%


function data=probeDAS(shot,style)

% handle input
assert(nargin==2,'ERROR: invalid number of inputs')
target=DASfile(shot,style);

switch lower(style)
    case {'s','saturn'}
        object=SMASH.FileAccess.DigitizerFile(target,'saturn');
    otherwise
        object=SMASH.FileAccess.DigitizerFile(target,'zdas');
end
data=probe(object);

end