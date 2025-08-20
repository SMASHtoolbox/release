% compare Compare signals
%
% This method compares two signals, determining how similar they could be.
% In other words, can the second signal be made to match first signal by
% linear transformations in the horizontal and/or vertical direction? 
%    x'=a+bx    y'=c+dy
% These transformations are controlled by four parameters: HorizontalShift
% (a), HorizontalScale (b), VerticalShift (c), and VerticalScale (d).
% 
% Comparing two signals generates a parameter report.
%    report=compare(objectA,objectB,list,bound);
% The input "list" defines the adjustable parameters as a string or cell
% array of strings.  For example, {'HorizontalShift' 'VerticalScale'}
% indicates horizontal shifting and vertical scaling only; the default
% value {'HorizontalShift'} invokes time shifting only.  The output
% "report" is a structure with fields matching the requested parameter
% list.
%
% The input "bound" defines the horizontal bounds for signal comparison.
% These bounds are specified as a two-column table: 
%    [leftA rightA; leftB rightB] % separate bounds
%    [left right] % common bound
% Interactive selection mode is launched when no bounds are specified.
%
% Additional outputs return a scaled/shifted version of the second signal
% and a Curve object for uncertainty analysis.
%    [report,newB,model]=compare(...);
%
% Examples:
%    <a href="matlab:SMASH.System.showExample('CompareExampleA','+SMASH/+SignalAnalysis/@Signal')">Horizontal shift</a>
%
% See also Signal, locate, SMASH.CurveFit.Curve
%

%
% created April 8, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=compare(objectA,objectB,list,bound)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(strcmpi(class(objectA),class(objectB)),...
    'ERROR: invalid second signal');

if (nargin < 3) || isempty(list)
    list={'HorizontalShift'};
elseif ischar(list)
    list={list};
else
    assert(iscellstr(list),'ERROR: invalid parameter list');
end
adjust=false(4,1);
for n=1:numel(list)
    switch lower(list{n})
        case 'horizontalscale'
            adjust(1)=true;
        case 'horizontalshift'
            adjust(2)=true;        
        case 'verticalscale'
            adjust(3)=true;
        case 'verticalshift'
            adjust(4)=true;
        otherwise
            error('ERROR: "%s" is not a valid parameter',list{n});
    end        
end

if (nargin < 4) || isempty(bound) || strcmpi(bound,'select')
    h(1)=view(objectA);
    h(2)=view(objectB,gca);
    h(2).Color='r';
    legend(h,'Signal A','Signal B','Location','best','AutoUpdate','off');
    selection(1)=SMASH.ROI.Rectangle('x');
    selection(1).Name='Signal A bound';
    selection(2)=SMASH.ROI.Rectangle('x');
    selection(2).Name='Signal B bound';
    selection=manage(selection,'Fixed',true);        
    bound(1,:)=selection(1).Data;
    bound(2,:)=selection(2).Data;
    close(ancestor(h(1),'figure'));
elseif strcmpi(bound,'all')
    bound=repmat([-inf inf],[2 1]);
elseif isnumeric(bound) && ismatrix(bound)
    if numel(bound) == 2
        bound=repmat([bound(1) bound(2)],[2 1]);
    else
        assert(all(size(bound) == 2),'ERROR: invalid bound');
    end
    bound=sort(bound,2,'ascend');
else
    error('ERROR: invalid bound');
end

% deal with infinite bounds
errmsg='ERROR: invalid horizontal bound';

if isinf(bound(1,1))
    assert(bound(1,1) < 0,errmsg);
    bound(1,1)=min(objectA.Grid);
end

if isinf(bound(1,2))
    assert(bound(1,2) > 0,errmsg);
    bound(1,2)=max(objectA.Grid);
end

if isinf(bound(2,1))
    assert(bound(2,1) < 0,errmsg);
    bound(2,1)=min(objectB.Grid);
end

if isinf(bound(2,2))
    assert(bound(2,2) > 0,errmsg);
    bound(2,2)=max(objectB.Grid);
end

% set up analysis
A=crop(objectA,bound(1,:));
B=crop(objectB,bound(2,:));

model=SMASH.CurveFit.Curve([A.Grid A.Data]);
    function out=basis(p,x)               
        out=B;
        if adjust(1)
            out=scale(out,p(1));
            p=p(2:end);
        end
        if adjust(2)
            out=shift(out,p(1));
            if p(1) > 0
                padval=out.Data(1);
            else
                padval=out.Data(end);
            end
        end
        out=regrid(out,x);
        out=replace(out,isnan(out.Data),padval);
        out=out.Data;
    end
guess=[];
if adjust(1)
    guess(end+1)=1;   
end
if adjust(2)
    guess(end+1)=-diff(mean(bound,2));
end
model=add(model,@basis,guess);

if adjust(3)
    model=edit(model,1,'fixscale',false);
else
    model=edit(model,1,'fixscale',true,'scale',1);
end

model=add(model,@(p,x) ones(size(x)),[]);
if adjust(4)
    model=edit(model,2,'fixscale',false);
else
    model=edit(model,2,'fixscale',true,'scale',0);
end

% perform analysis
model=fit(model);
param=summarize(model);
p=param(1).Parameter;

report.HorizontalScale=1;
if adjust(1)
    report.HorizontalScale=p(1);
    p=p(2:end);
end

report.HorizontalShift=0;
if adjust(2)
    report.HorizontalShift=p(1);
end

report.VerticalScale=param(1).Scale;
report.VerticalShift=param(2).Scale;

% manage output
if nargout == 0
    disp(report);
    return
end

if nargout >= 1
    varargout{1}=report;
end

if nargout >= 2
    new=scale(objectB,report.HorizontalScale);
    new=shift(new,report.HorizontalShift);
    new=report.VerticalScale*new+report.VerticalShift;
    varargout{2}=new;
end

if nargout >= 3
    varargout{3}=model;
end

end