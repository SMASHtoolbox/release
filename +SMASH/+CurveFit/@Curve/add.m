% add Add basis function
%
% This method adds a basis function to a Curve object.  The basic syntax
% is:
%    >> object=add(object,basis,parameter);
% where "basis" should be a hande to a function that accepts two inputs,
% e.g:
%     y=basis(p,x);
% The input "parameter" is passed to the basis function whenever the Curve
% object is evaluated.
% 
% Additional inputs can be used to control how the basis function is used.
% The following name/value pairs can be used during basis addition.
%     >> object=add(...,'lower',bound); % specify parameter bounds (default is -inf)
%     >> object=add(...,'upper,bound); % specify parameter bounds (default is +inf)
%     >> object=add(...,'scale',value); % specify scaling factor (default is 1)
%     >> object=add(...,'fixscale',value); % specify fixed scaling (default is false)
% Options used in the same call apply to a single basis function.  For
% example:
%     >> object=add(object,basis,param,'lower',lower,'upper',upper);
% defines upper and lower boundaries for a single basis function.
% Separating the options:
%     >> object=add(object,basis,param,'upper',upper);
%     >> object=add(object,basis,param,'lower',lower);
% defines two basis functions sharing the same form and parameter state but
% different parameter bounds.
%
% See also Curve, edit, remove, summarize
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=add(object,basis,parameter,varargin)

% handle input
assert(nargin>=3,'ERROR: insufficient input');

if ischar(basis)
    basis=str2func(basis);
end
assert(isa(basis,'function_handle'),'ERROR: invalid basis function');

assert(isnumeric(parameter),'ERROR: invalid param array');
Nparam=numel(parameter);
parameter=reshape(parameter,[1 Nparam]);

option=struct('Lower',-inf(1,Nparam),'Upper',+inf(1,Nparam),...
    'Scale',1,'FixScale',false);
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid name');
    value=varargin{n+1};
    switch lower(name)
        case 'lower'
            if isempty(value)
                value=-inf;
            end
            if numel(value)==1
                value=repmat(value,[1 Nparam]);
            end
            assert(numel(value)==Nparam,'ERROR: invalid lower bound');
            option.Lower=reshape(value,[1 Nparam]);
        case 'upper'
            if isempty(value)
                value=+inf;
            end
            if numel(value)==1
                value=repmat(value,[1 Nparam]);
            end
            assert(numel(value)==Nparam,'ERROR: invalid upper bound');
            option.Upper=reshape(value,[1 Nparam]);
        case 'scale'
            assert(isnumeric(value) & isscalar(value),...
                'ERROR: invalid Scale');
            option.Scale=value;
        case 'fixscale'
            assert(islogical(value) & (numel(value)==1),...
                'ERROR: FixScale must be true or false');
            option.FixScale=value;
        otherwise
            error('ERROR: ''%s'' is an invalid name',name);
    end
end

assert(all(option.Upper>=option.Lower),'ERROR: inconsistent bounds');

% update object
object.Basis{end+1}=basis;
object.Parameter{end+1}=parameter;
object.Bound{end+1}=[option.Lower; option.Upper];
object.Scale{end+1}=option.Scale;
object.FixScale{end+1}=option.FixScale;

object.FitComplete=false;

end