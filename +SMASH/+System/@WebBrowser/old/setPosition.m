% UNDER CONSTRUCTION
function setPosition(value)

persistent getPosition
if isempty(getPosition)
    getPosition=@() SMASH.System.WebBrowser.getPosition();
end

% manage input
if isnumeric(value)
    switch numel(value)
        case 2
            pos=object.Position;
            pos(1:2)=value;
            value=pos;
        case 4
            % keep going
        otherwise
            error('ERROR: invalid position array');
    end
elseif ischar(value)
    fig=figure('Visible','off','Units','pixels');
    CU=onCleanup(@() close(fig));
    fig.OuterPosition=getPosition();
    try
        movegui(fig,value);
    catch
        error('ERROR: invalid position name');
    end
    value=get(fig,'OuterPosition');
else
    error('ERROR: invalid position');
end

% apply setting
value=round(value);

pos=get(groot,'ScreenSize');
x0=value(1);
y0=pos(4)-value(2)-value(4);

master=getMaster();
master.setLocation(x0,y0);
master.setSize(value(3),value(4));

end
