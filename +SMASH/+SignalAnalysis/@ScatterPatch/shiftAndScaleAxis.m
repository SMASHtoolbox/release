% UNDER CONSTRUCTION

function shiftAndScaleAxis(object, varargin)

if numel(object) > 1
    error('Result object arrays not supported')
end

% manage options

option = struct('Axis', [], 'Shift', [], 'Scale', []);

try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

if isempty(option.Axis) || (~strcmpi(option.Axis, 'Horizontal') && ...
        ~strcmpi(option.Axis, 'Vertical') && ~strcmpi(option.Axis, ...
        'x') && ~strcmpi(option.Axis, 'y'))
    option.Axis = 'Horizontal';
    disp('No axis selected - default Horizontal assumed')
end

if isempty(option.Shift)
    option.Shift = 0;
end

if isempty(option.Scale)
    option.Scale = 1;
end

% scale and shift

if strcmpi(option.Axis, 'Horizontal') || strcmpi(option.Axis, 'X')
    ind = 1;
else
    ind = 2;
end

object.RawData(:,ind) = option.Scale*(object.RawData(:,ind) + option.Shift);
object.RawData(:,ind+2) = option.Scale*object.RawData(:,ind+2);

end