% summarize Summarize parameter values
%
% This method prints a summary of the current parameter state to the
% command window.
%    summarize(object);
% Parameters are written line by line in the format:
%     [name] : [value] ([min] to [max])
% The default numeric format uses six significant digits.  This can be
% changed by passing addition inputs.
%    summarize(object,digits,force);
% The second input controls the number of significant digits printed in
% compact (%g) format, where insignficant digits are suppressed.  Passing
% 'force' as the third input prints all requested digits.
%
% See also BoundParameter
%

%
% created September 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function summarize(object,digits,force)

% manage input
if (nargin < 2) || isempty(digits)
    digits=6;
end
assert(any(digits == 1:15),'ERROR: invalid number of digits requested');

if (nargin < 3) || isempty(force)
    force=false;
elseif strcmp(force,'force')
    force=true;
else
    force=false;
end

% print summary
fprintf('Parameter summary\n');

L=max(cellfun(@numel,object.ParameterName));
if force
    label=sprintf('\\t%%%ds : %%#+.%dg (%%#+.%dg to %%#+.%dg)\n',...
        L,digits,digits,digits);
else
    label=sprintf('\\t%%%ds : %%+.%dg (%%+.%dg to %%+.%dg)\n',...
        L,digits,digits,digits);
end


for n=1:object.NumberParameters
    fprintf(label,object.ParameterName{n},object.Parameter(n),object.Bound(n,1),object.Bound(n,2));
end

end