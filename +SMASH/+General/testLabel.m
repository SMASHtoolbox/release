% testLabel Check for valid label
%
% This function determines if a value is a valid labe.
%    status=testLabel(value);
% The output "status" is true when the input "value" is a character array,
% a cell array of characters, or a string variable.  The output is false in
% all other cases.
%
% See also SMASH.General
%
% 
function success=testLabel(value)

if ischar(value) || isstring(value)  || iscellstr(value)
    success=true;
else
    success=false;
end

end