% checkDisplay Check monitor information
%
% This method reports the available monitors in the current MATLAB session.
% Calling the method with no outputs:
%    checkDisplay();
% prints a list of monitor information in the command window.  This
% information is returned as a data structure as requested.
%    data=checkDisplay();
% This structure contains the monitor size, origin (lower left corner
% coordinates), bound (upper right cooridates), resolution (dots per inch),
% and logical value indicating if new figures spawn on the figure.
% Requesting a second output:
%    [data,spawn]=checkDisplay();
% returns the spawn monitor for new figures.
%
% <a href="matlab:SMASH.System.showExample('checkDisplay','+SMASH/+Graphics/+DisplayTools')">Examples</a>
% 
% See also SMASH.Graphics.DisplayTools
%

%
% created December 14, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=checkDisplay()

% generate test figure
TestFigure=figure('Visible','on','Units','pixels');
pos=TestFigure.OuterPosition;
delete(TestFigure);
center=pos(1:2)+pos(3:4)/2;

% probe monitors
pos=get(groot,'MonitorPositions');
N=size(pos,1);
data=struct('Size',[],'Origin',[],'Bound',[],'ActualResolution',[]);
data=repmat(data,[N 1]);
spawn=1;
for n=1:N
    data(n).Origin=pos(n,1:2);
    data(n).Size=pos(n,3:4);
    data(n).Bound=data(n).Origin+data(n).Size;
    data(n).SetResolution=get(groot,'ScreenPixelsPerInch');
    data(n).ActualResolution=getScreenResolution();
    if all(center >= data(n).Origin) && all(center <= data(n).Bound)
        spawn=n;
    end
    data(n).Spawn=false;
end
data(spawn).Spawn=true;


% manage output
switch nargout
case 0 % print results        
        for n=1:N
            fprintf('Monitor #%-2d: ',n);
            fprintf('size = [%d %d], ',data(n).Size);
            fprintf('origin = [%+d %+d], ',data(n).Origin);
            fprintf('DPI = %g ',data(n).ActualResolution)            
            fprintf('\n');
        end       
        fprintf('   New figures created on monitor #%-2d\n',spawn);        
    case 1 % standard use
        varargout{1}=data;
    otherwise % return spawn point
        varargout{1}=data;
        varargout{2}=spawn;        
end  

end