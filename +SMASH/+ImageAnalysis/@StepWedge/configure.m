% configure Configure analysis settings
%
% This method configures settings used by the analysis method.
% Configurations are specified by name/value pairs.
%     >> object=configure(object,name1,value1,...);
% Valid settings include:
%   StepLevels       : array of optical densities for the step wedge
%   StepOffsets      : array of density offsets overlad on the step wedge
%   DerivativeParams : numerical differentiation settings [order size]
%   HorizontalMargin : margin between boundary and step region (fractional) 
%   VerticalMargin   : margin between boundary and step region (fractional)
%   AnalysisRange    : density range used for linearization (fractional)
%   PolynomialOrder  : polynomial order used in linearization
% Specifying an empty value, e.g.:
%     >> object=configure(object,'AnalysisRange',[]);
% resets the setting to its default value.
%
% Calling this method with no inputs or outputs:
%     >> configure(object);
% displays the current settings.
%
% See also StepWedge, analyze

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=configure(object,varargin)

% mange input
Narg=numel(varargin);
if Narg==0
    assert(nargout==0,'ERROR: no output can be generated without input');
    disp(object.Settings);    
    return
end

assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');

setting=object.Settings;
valid=fieldnames(setting);
Nfield=numel(valid);
for m=1:2:Narg
    name=varargin{m};
    assert(ischar(name),'ERROR: invalid name');
    found=false;
    for n=1:Nfield
        if strcmpi(name,valid{n})            
            found=true;
            break
        end
    end
    setting.(valid{n})=varargin{m+1};
    assert(found,'ERROR: %s is an invalid name');
end

% error checking
value=setting.ID;
if isempty(value)
    value=object.DefaultID;
end
assert(ischar(value),'ERROR: invalid ID value');
seting.ID=value;

value=setting.StepLevels;
if isempty(value)
    value=object.DefaultStepLevels;
end
assert(isnumeric(value) && numel(value)>1 && all(value>=0),...
    'ERROR: invalid StepLevels value');
value=reshape(value,[1 numel(value)]);
value=sort(value);
setting.StepLevels=value;

value=setting.StepOffsets;
if isempty(value)
    value=object.DefaultStepOffsets;
end
assert(isnumeric(value) && numel(value)>0 && all(value>=0),...
    'ERROR: invalid StepOffsets value');
value=reshape(value,[1 numel(value)]);
value=sort(value);
setting.StepOffsets=value;

value=setting.DerivativeParams;
if isempty(value)
    value=object.DefaultDerivativeParams;
end
assert(isnumeric(value) && numel(value==2) ...
    && all(value>0),...
    'ERROR: invalid DerivativeParams value');
setting.DerivativeParams=value;

value=setting.HorizontalMargin;
if isempty(value)
    value=object.DefaultHorizontalMargin;
end
assert(isnumeric(value) && isscalar(value) ...
    && (value>0) && (value<1),...
    'ERROR: invalid HorizontalMargin value');
setting.HorizontalMargin=value;

value=setting.VerticalMargin;
if isempty(value)
    value=object.DefaultVerticallMargin;
end
assert(isnumeric(value) && isscalar(value) ...
    && (value>0) && (value<1),...
    'ERROR: invalid VerticalMargin value');
setting.VerticalMargin=value;

value=setting.AnalysisRange;
if isempty(value)
    value=object.DefaultAnalysisRange;
end
assert(isnumeric(value) && (numel(value)==2) ...
    && all(value>0) && all(value<1),...
    'ERROR: invalid AnalysisRange value');
value=sort(value);
setting.AnalysisRange=value;

value=setting.PolynomialOrder;
if isempty(value)
    value=object.DefaultPolynomialOrder;
end
assert(SMASH.General.testNumber(value,'integer') &&  (value>0), ...
    'ERROR: invalid PolynomialOrder value');
setting.PolynomialOrder=value;

% finish up
object.Settings=setting;
varargout{1}=object;

end       