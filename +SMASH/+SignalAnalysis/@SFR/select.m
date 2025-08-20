% select Select region(s) of interest
%
% This method selects regions of interest for frequency reduction.  This is
% usually done interactively with an existing preview.
%    select(object,index);
% Omitting the input "index" uses the most recent preview.  An integer
% index can be used to specify:
%    -The most recent preview (index=0).
%    -An offset from the most recent preview (index < 0).
%    -An offset from the first preview (index > 0).
% Note that interactive selection can only be performed on one object at a
% time.  Regions are stored with the object between iterative selections. 
% 
% Manual region selections are defined by a sequence of source variables.
%    select(object,source1,source2,...);
% Each source variable can be a:
%    -Three-column array [time frequency uncertainty].
%    -The name of a text file with three numeric columns [time frequency uncertainty].
%    -Another SFR object.
% Source selections are transferred to the Selection property, overwriting
% any existing selections.  Passing the object as another source:
%    select(object,object,source1,...);
% merges previous selections with manual definitions.  
%
% Region definitions can always be cleared from the object.
%    select(object,'clear'); 
%
% See also SFR, preview, reduce
%
function select(object,varargin)

% manage input
if nargin == 1
    varargin{1}=0;
end

if isnumeric(varargin{1}) && isscalar(varargin{1})
    assert(isscalar(object),...
        'ERROR: interactive selection must use one object at a time');
    try
        selectROI(object,varargin{1});
    catch ME
        throwAsCaller(ME);
    end
    return
elseif strcmpi(varargin{1},'clear')
    for k=1:numel(object)
        object(k).Selection=[];
    end
    return
end

selection=[];
while ~isempty(varargin)
    source=varargin{1};
    try
        if isnumeric(source)
            new=readData(source);
        elseif ischar(source) || isstring(source)
            new=readFile(source);
            if isempty(new) % file selection cancelled
                return
            end
        elseif isa(source,class(object))
            assert(isscalar(object));
            new=source.Selection;
        end
    catch ME
        throwAsCaller(ME);
    end
    selection=[selection new]; %#ok<AGROW>
    varargin=varargin(2:end);
end

for k=1:numel(object)
    object(k).Selection=selection;
end

end

%% interactive selection
function selectROI(object,index)

if isempty(object.Preview)
    fprintf('Generating preview...');
    preview(object,'Plot','off');
    fprintf('done\n');
end

plot(object,'preview','Index',index);
fig=gcf();

selection=object.Selection;
if isempty(selection)
    selection=SMASH.ROI.Curve('x');
end
selection=manage(selection,'Target',fig);
delete(fig);

keep=true(size(selection));
for n=1:numel(selection)
    if isempty(selection(n).Data)
        keep(n)=false;
    end
end

if sum(keep) > 0
    object.Selection=selection(keep);
else
    object.Selection=[];
end

end

%% manual selections (data, file, source object)
function out=readData(in)

assert(ismatrix(in),'ERROR: invalid selection array');
[rows,columns]=size(in);
assert(columns == 3,'ERROR: selection array must have three columns');
assert(rows >= 2,'ERROR: selection array must have at least two rows');
assert(all(in(:,3) > 0),'ERROR: uncertainties must be > 0');

out=SMASH.ROI.Curve('x');
out=define(out,in);

end

function out=readFile(file)

out=[];
if isempty(file)
    [file,location]=uigetfile({'*.*' 'All files (*.*)'},...
        'Select ROI file');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
elseif contains(file,'*')
    file=dir(file);
    while ~isempty(file)
        new=readFile(fullfile(file(1).folder,file(1).name));
        out=[out new]; %#ok<AGROW>
        file=file(2:end);
    end
    return
end

data=SMASH.FileAccess.readFile(file,'column');
out=readData(data.Data);

end