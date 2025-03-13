% enprint Print with engineering notation
%
% This function prints a number with engineering notation.
%    result=enprint(number);
% The output "result" displays the number in modified scientific notation.
%   -Exponents are always factors of three.
%   -Mantissa and exponents signs are always displayed.
% The default number of mantissa digits is three.  The number of mantissa
% digits can be changed with a second input.
%   result=enprint(number,digits);
%
% The input "digits" can be a two-element array.  The second element
% controls the *minimum* number of exponent digits.  For example:
%    result=enprint(number,[6 2]);
% prints 6 digits of mantissa and two exponent digits.  Minimum exponent
% digits can be 1, 2, or 3 (default).  Exponents that exceed the requessted
% number of digits are always printed correctly.
%
% If no output is specified, the formatted result is printed in the command
% window.
%
% See also SMASH.General, sigprint
%

%
% created December 3, 2015 by Daniel Dolan (Sandia National Laboratories)
% updated March 8, 2019 by Chris De La Cruz
%    -Minimum number of exponent digits (1, 2, or 3) now supported
%
function varargout=enprint(number,digits)

% manage input
assert(nargin>=1,'ERROR: insufficient input');

assert(isnumeric(number) && isscalar(number),...
    'ERROR: invalid number');

if (nargin<2) || isempty(digits)
    digits=3;
end
assert(isnumeric(digits),'ERROR: invalid digits value');
if isscalar(digits)
    digits(2)=3;
end
assert((numel(digits)==2) && all(digits>0) && all(digits==round(digits)),...
    'ERROR: invalid digits value');
assert(any(digits(2)==[1 2 3]),'ERROR: invalid digits value');

% process number
if isnan(number) || isinf(number)
    result=sprintf('%+g',number);
else
    if number>=0
        result='+';
    else
        result='-';
    end
    number=abs(number);    
    if number==0
        mantissa=0;
        exponent=0;
    else
        exponent=3*floor(log10(number)/3);
        mantissa=number/(10^exponent);
    end
    
    format=sprintf('%%c%%#.%dgE%%+0%dd',digits(1),digits(2)+1);
    result=sprintf(format,result,mantissa,exponent);
    
end

% manage output
if nargout>0
    varargout{1}=result;
else
    fprintf('%s\n',result);
end

end