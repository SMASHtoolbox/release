% selectROI Select region of interest
%
% This function provides interactive region of interest selection.  A basic
% call:
%   result=selectROI(); 
% prompts the user to choose a region type and then make selections on the
% current axes.
%
% Region type and mode can be specified as the first input.
%    result=selectROI(type); % use default mode
%    result=selectROI({type mode}); % specify selection type mode
%
% A second input, if present, specifies the target axes for interactive
% selections.
%    result=selectROI(type,target);
%
% See also SMASH.ROI
%

%
% created March 2, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function result=selectROI(type,target)

% manage input
if (nargin < 2) || isempty(target)
    target=gca;
else
    assert(ishandle(target),'ERROR: invalid target axes');
end

if nargin < 1
    [type,mode]=chooseRegionType();    
elseif ischar(type)
    mode='';
elseif iscellstr(type)
    mode=type{2};
    type=type{1};
else
    error('ERROR: invalid ROI type');
end

% select ROI
try
    name=lower(type);
    name(1)=upper(name(1));
    result=packtools.call(name,mode);
catch
    error('ERROR: invalid ROI type');
end
result=select(result,target);

end

function [type,mode]=chooseRegionType()

box=SMASH.MUI.Dialog();
box.Hidden=true;
box.Name='ROI type';

RegionType={'Rectangle' 'Points' 'Curve' 'Slices'};   
TypeList=addblock(box,'popup','Region type: ',RegionType);
set(TypeList(2),'Callback',@updateType)
ModeList=addblock(box,'popup','Region mode: ',{''});
description=addblock(box,'medit','Description:',40,5);
set(description(2),'Style','text');
done=addblock(box,'button',' Done ');
set(done,'Callback','delete(gcbo)');
locate(box,'center');
updateType();
box.Hidden=false;
waitfor(done);

if ~ishandle(box.Handle)
    return
end
value=probe(box);
delete(box);

type=value{1};
mode=value{2};

    function updateType(varargin)
        value=probe(box);
        message={};
        switch lower(value{1})
            case 'rectangle'
                message{end+1}='Finite, semi-infinite, or infinite rectangular regions';
            case 'points'
                message{end+1}='Open, connected, closed, or convex group of points';
            case 'curve'
                message{end+1}='Curve defined by sorted, connected points';
                message{end+1}='   Single-valued functions y=f(x) or x=g(y)';
            case 'slices'
                message{end+1}='Vertical or horizontal slices';           
        end
        set(description(2),'String',message);
        result=packtools.call(value{1});
        set(ModeList(2),'Value',1,'String',result.ValidModes);        
    end

end