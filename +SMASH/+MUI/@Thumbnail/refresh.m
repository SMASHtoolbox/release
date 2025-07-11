% refresh Update axes
%
% This methods updates the locations and appearances of axes in a thumbnail
% arrangment.
%    refresh(object);
% Changing the size/location property automatically calls this method.
% Manual refreshes are recommended when new plot objects (lines, images,
% etc.) are added, especially when these additions are made on a thumbnail.
%
% Custom updates can be applied at the end of the refresh process.  These
% operations are defined by a function handle in the UpdateFcn property.
%    object.UpdateFcn=@myfunc;
% The function "myfunc" should accept the Thumbail object as an input,
% e.g.:
%    function myfunc(object)
%    ...
%
% See also Thumbnail, promote
%

%
% created August 16, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function refresh(object)

% find axes objects
if isempty(object.Axes)
    return
end

Naxes=numel(object.Axes);
main=object.Axes(1);
sub=object.Axes(2:end);

% position main axes
fraction=object.Fraction;
switch object.Location
    case 'bottom'
        MainPos=[0 fraction 1 1-fraction]; 
        width=1/(Naxes-1);
        SubPos=[0 0 width fraction];
        SubShift=[width 0 0 0];
    case 'top'
        MainPos=[0 0 1 1-fraction]; 
        width=1/(Naxes-1);
        SubPos=[0 1-fraction width fraction];
        SubShift=[width 0 0 0];
    case 'left'
        MainPos=[fraction 0 1-fraction 1]; 
        height=1/(Naxes-1);
        SubPos=[0 1-height fraction height];
        SubShift=[0 -height 0 0];
    case 'right'
        MainPos=[0 0 1-fraction 1];
        height=1/(Naxes-1);
        SubPos=[1-fraction 1-height fraction height];
        SubShift=[0 -height 0 0];
end
set(main,'Units','normalized','OuterPosition',MainPos,'ButtonDownFcn','');
temp=get(main,'Children');
set(temp,'HitTest','on');

% position sub axes
for n=1:numel(sub)
    set(sub(n),'Units','normalized','OuterPosition',SubPos);
    SubPos=SubPos+SubShift;
    temp=get(sub(n),'Children');
    set(temp,'HitTest','off');
    set(sub(n),'ButtonDownFcn',@promoteAxes);
end

    function promoteAxes(src,~)
        promote(object,src);
    end

if isa(object.UpdateFcn,'function_handle')
    object.UpdateFcn(object);
end

end