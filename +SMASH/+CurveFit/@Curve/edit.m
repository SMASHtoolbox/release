% edit Edit basis
%
% This method edits an basis for a Curve object.  Basis are are referenced
% by the order in which they were added.
%     >> object=edit(object,index,name1,value1,...);
% Name/value pairs indicate the requested changes.  Valid names are
% 'function', 'parameter', 'upper', 'lower', 'scale', and 'fixscale'; for more
% information about each name, see the add method.
%
% Modifications to basis parameters and bounds are always allowed, but the
% number of parameters cannot be modified!  If the number of parameters
% must be changed (basis function modification, mistakes when the basis was
% added, etc.), then the basis must be removed and the added again.
%
% See also Curve, add, remove, summarize
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=edit(object,index,varargin)

% handle input
assert(nargin>2,'ERROR: insufficient input');
assert(isscalar(index),'ERROR: invalid index');
M=numel(object.Basis);
valid=1:M;
assert(any(index==valid),'ERROR: invalid index');

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
Nparam=numel(object.Parameter{index});
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{n+1};
    switch lower(name)                   
        case 'function'
            if ischar(value)
                value=str2func(value);                
            end
            assert(isa(value,'function_handle'),...
                'ERROR: invalid basis function');
            object.Basis{index}=value;
        case 'parameter'
            assert(isnumeric(value),'ERROR: invalid parameter array');            
            if numel(value)~=Nparam               
                Nparam=numel(value);
                temp=+inf(2,Nparam);
                temp(1,:)=-temp(1,:);
                object.Bound{index}=temp;
            end
            object.Parameter{index}=value;
        case 'lower'
            assert(isnumeric(value),'ERROR: invalid lower bound array');  
            assert(Nparam==numel(value),'ERROR: incompatible array size');
            object.Bound{index}(1,:)=value;
        case 'upper'
            assert(isnumeric(value),'ERROR: invalid upper bound array');
            assert(Nparam==numel(value),'ERROR: incompatible array size');
            object.Bound{index}(2,:)=value;
        case 'scale'
             assert(isnumeric(value) & isscalar(value),'ERROR: invalid scale'); 
             object.Scale{index}=value;
        case 'fixscale'
            assert(islogical(value) & isscalar(value),'ERROR: invalid FixScale value');
            object.FixScale{index}=value;
        otherwise
            error('ERROR: "%s" is an invalid name');
    end
end

object.FitComplete=false;

end