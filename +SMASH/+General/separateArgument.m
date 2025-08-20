% separateArgument Separate argument list
%
% This function separates an argument list into the following categories.
%     -Position arguments are non-character values referenced by numeric
%     index.  Empty values and characters beginning with an asterisk are
%     also treated as positional arguments.
%     -Name/value pairs combine a character name with an associated value.
%      Names *must* be valid MATLAB variables.
%     -Flag arguments are character values that begin with a dash.
%     -Assignment arguments are character arrays that contain *one* equal
%     sign.  Multiple equal signs will generate an error.
%
% The calling sequence:
%    report=separateArgument(list);
% accepts an argument list (cell array) and returns a report structure.
% The output structure has the fields Position, Pair, Flag, and Assignment
% for each argument category.
%
% See also SMASH.General, isvarname
%

%
% created January 25, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function report=separateArgument(varargin)

Position={};
Flag={};
Assignment={};
%for k=1:nargin
while numel(varargin) > 0
    if ischar(varargin{1})
        if isempty(varargin{1}) || (varargin{1}(1) == '*')
            Position{end+1}=varargin{1}; %#ok<AGROW>
            varargin=varargin(2:end);
        elseif isvarname(varargin{1})
            if numel(varargin) < 2
                error('ERROR: unmatched name/value pair');
            end
            report.(varargin{1})=varargin{2};
            varargin=varargin(3:end);
        elseif varargin(1) == '-'
            Flag{end+1}=varargin{1}; %#ok<AGROW>
            varargin=varargin(2:end);
        elseif sum(varargin{1} == '=') == 1
            Assignment{end+1}=varargin{1}; %#ok<AGROW>
             varargin=varargin(2:end);
        else
            error('ERROR: invalid input argument');
        end                   
    else
        Position{end+1}=varargin{1}; %#ok<AGROW>
    end
end

report.Position=Position;
%report.Pair=Pair;
report.Flag=Flag;
report.Assignment=Assignment;

end