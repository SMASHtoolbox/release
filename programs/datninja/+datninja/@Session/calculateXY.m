% 
function data=calculateXY(object,ref)

assert(~isempty(object.ParameterMatrix),...
    'ERROR: not enough reference points');

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(isnumeric(ref) && (numel(ref) >= 2),...
    'ERROR: invalid reference array');
if nargin == 2
    ref=reshape(ref,[1 2]);
else
    assert(size(ref,2) == 2,'ERROR: reference array must have two columns');
end

% perform mapping
M=size(ref,1);
Q=ones(M,3);
Q(:,2:3)=ref;
data=Q*object.ParameterMatrix;

% log scaling
switch object.LogScaling
    case {'horizontal' 'both'}
        data(:,1)=10.^(data(:,1));
end

switch object.LogScaling
    case {'vertical' 'both'}
        data(:,2)=10.^(data(:,2));
end

end