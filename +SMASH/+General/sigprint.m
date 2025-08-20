% sigprint Uncertainty-based printing of signficant digits
%
% This function prints a numeric value based on a specified uncertainty.
%    [vstr,ustr]=sigprint(value,uncertainty);
% The output strings "vstr" and "ustr" are formatted versions of the inputs
% "value" and "uncertainty".  The uncertainty string uses one
% significant digit by default; the number of value string digits depends
% on the location of this uncertainty digit.  Both strings are formatted in
% scientific notation using a common exponent and the same number of
% characters (zero padding as necessary).  Postive/negative signs are shown
% at the start of each string.
%
% Output string format can be modified by passing option name/value pairs.
%    [...]=sigprint(...,name,value);
% Valid options include:
%    -'Digits' controls the number of significant digits in the uncertainty
%    string.  Although any integer from 1-15 can be specified, this value
%    is typically 1-2.
%    -'Convention' determines how moderate size values are printed.  The
%    default value 'scientific' always uses scientific notation, whereas
%    'flexible' uses floating point notation for exponents from -3 to +3.
%    -'ForceSign' places positive/negative signs at the beginning of the
%    output string (default value is true).  Changing this option to false
%    replaces extraneous positive signs with empty space.
%
% When no outputs are specified, the value and uncertainty strings are
% printed in the command window.
%
% <a href="matlab:SMASH.System.showExample('sigprintExamples','+SMASH/+General')">Examples</a>
%
% See also SMASH.General, enprint
%

%
% created June 24, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=sigprint(value,uncertainty,varargin)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');

assert(isnumeric(value) && isscalar(value),'ERROR: invalid value');
assert(isnumeric(uncertainty) && isscalar(uncertainty) && (uncertainty > 0),...
    'ERROR: invalid value');

Narg=numel(varargin);
if (Narg == 1) && isstruct(varargin{1})
    option=varargin{1};
    Narg=0;
else
    assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
    option.Digits=1;
    option.Convention='scientific';
    option.ForceSign=true;
end
for n=1:2:Narg
    OptionName=varargin{n};
    assert(ischar(OptionName),'ERROR: invalid option name');
    OptionValue=varargin{n+1};
    switch lower(OptionName)
        case 'digits'
            assert(SMASH.General.testNumber(OptionValue,'integer','positive','notzero'),...
                'ERROR: invalid number of uncertainty digits');
            option.Digits=OptionValue;
        case 'convention'
              assert(ischar(OptionValue),...
                  'ERROR: invalid format convention');
              switch lower(OptionValue)
                  case 'scientific'
                      option.Convention='scientific';
                  case 'flexible'
                      option.Convention='flexible';
                  otherwise             
                      error('ERROR: %s is not a valid convention',OptionValue);
              end
        case 'forcesign'
            if isnumeric(OptionValue)
                OptionValue=logical(OptionValue);
            end
            assert(isscalar(OptionValue) && islogical(OptionValue),...
                'ERROR: invalid force sign value');
            option.ForceSign=OptionValue;
        otherwise
            error('ERROR: %s is not a valid option name',OptionValue);
    end
end

% parse uncertainty
format=sprintf('%%#+.%dE',option.Digits-1);
temp=sprintf(format,uncertainty);
index=strfind(temp,'E');
sig1=temp(1:index-1);
exp1=temp(index+1:end);

% parse value
temp=sprintf('%#+.15E',value);
index=strfind(temp,'E');
sig2=temp(1:index-1);
exp2=temp(index+1:end);

% combine results
N=numel(sig1)-3;
sig1=sscanf(sig1,'%f',1);
sig2=sscanf(sig2,'%f',1);

shift=sscanf(exp2,'%d')-sscanf(exp1,'%d');
if N+shift >= 0
    format=sprintf('%%#+.%df',N+shift);
else
    format='%#+.0f';
end
sig1=sprintf(format,sig1/(10^shift));
sig2=sprintf(format,sig2);
if shift < 0
    sig2=[sig2(1) repmat('0',[1 abs(shift)]) sig2(2:end)];
end

% format strings
value=[sig2 'E' exp2];
uncertainty=[sig1 'E' exp2];
switch option.Convention
    case 'scientific'
        % nothing to do
    case 'flexible'                
        M=sscanf(exp2,'%d',1);
        if (M < -3) || (M > +3)
            % nothing to do
        else
            value=shiftDecimal(sig2,M);
            uncertainty=shiftDecimal(sig1,M);            
            point=find(uncertainty == '.');
            temp=sscanf(uncertainty(1:point-1),'%d',1);
            uncertainty=[sprintf('%+d',temp) uncertainty(point:end)];       
        end
end

if option.ForceSign
    % nothing to do    
else
    if value(1) == '+'
        value(1)=' ';
    end
    uncertainty(1)=' ';
end

% manage output
if nargout == 0
    fprintf('   value       : %s\n',value);
    fprintf('   uncertainty : %s\n',uncertainty);
else
    varargout{1}=value;
    varargout{2}=uncertainty;
end

end

function out=shiftDecimal(in,M)

if M == 0
    out=in;
    return
end

k=strfind(in,'.');
if M > 0
    if k == numel(in)
        in(end+1)='0';
    end
    in(k)=in(k+1);
    in(k+1)='.';
    out=shiftDecimal(in,M-1);
else
    if k == 3
        in=[in(1) '0' in(2:end)];
        k=k+1;
    end
    in(k)=in(k-1);
    in(k-1)='.';
    out=shiftDecimal(in,M+1);
end

end
