% This program demonstrates Monte Carlo integration to estimate the value
% of pi.  When called without input:
%    MCdemo();
% the program launches a graphical interface for demonstrating random
% points drawn inside a square.  The ratio of points inside a nested
% circle approaches pi/4 as the number of draws goes to infinity.
% Demonstration begins with the "Start" menu and continues until the
% "Pause"/"Reset" menus are selected or 1 million samples are drawn.
%
% Passing an integer input:
%    MCdemo(N);
% bypasses the graphical interface and prints the result in the command
% window.  Estimates can also be returned as an output value.
%    estimate=MCdemo(N);
%

%
% created January 23, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=MCdemo(maxiter)

%%
if (nargin > 0) && isnumeric(maxiter)    
    assert(SMASH.General.testNumber(maxiter,'integer','positive','notzero'),...
        'ERROR: invalid number of draws');
    temp=2*rand(maxiter,2)-1;
    keep=sum(temp.^2,2) < 1;
    estimate=sum(keep)/size(keep,1)*4;
    if nargout == 0
        fprintf('estimate=%.9f\n',estimate);
        fprintf('      pi=%.9f\n',pi);
    else
        varargout{1}=estimate;        
    end
    return
end

maxiter=1e6;

%%
fig=figure('MenuBar','none','Name','Monte Carlo demonstration',...
    'IntegerHandle','off','HandleVisibility','callback');

radius=1;
theta=linspace(0,2*pi,500);
x=radius*cos(theta);
y=radius*sin(theta);
haxes=axes(fig,'Box','on','XTick',[],'YTick',[]);
plot(haxes,x,y,'k')
axis(haxes,'equal');
axis(haxes,'square');
haxes.XTick=[];
haxes.YTick=[];
title(haxes,cell(3,1));


hpoint(1)=line(haxes,'Marker','.','LineStyle','none','Color','r',...
    'XData',nan(maxiter,1),'YData',nan(maxiter,1));
hpoint(2)=line(haxes,'Marker','.','LineStyle','none','Color','b',...
    'XData',nan(maxiter,1),'YData',nan(maxiter,1));
iteration=[];
start=1;
count=[1 1];
label=cell(3,1);
label{3}=sprintf('pi value    = %.9f',pi);
wait=true;

hm=uimenu(fig,'Label','Program');
uimenu(hm,'Label','Start','Callback',@runMC);
    function runMC(varargin)
        wait=false;
        for iteration=start:maxiter
            if wait
                return
            end
            new=2*rand(1,2)-1;
            if hypot(new(1),new(2)) < radius
                count(1)=count(1)+1;
                hpoint(1).XData(count(1))=new(1);
                hpoint(1).YData(count(1))=new(2);
            else
                count(2)=count(2)+1;
                hpoint(2).XData(count(2))=new(1);
                hpoint(2).YData(count(2))=new(2);
            end
            label{1}=sprintf('%d points inside out of %d samples',count(1),iteration);
            label{2}=sprintf('pi estimate = %.9f',4*count(1)/iteration);
            title(haxes,label);
            drawnow();
        end
    end
uimenu(hm,'Label','Pause','Callback',@pauseMC);
    function pauseMC(varargin)
        start=iteration;
        wait=true;
    end
uimenu(hm,'Label','Reset','Callback',@resetMC);
    function resetMC(varargin)
        wait=true;
        for n=1:2
            hpoint(n).XData(:)=nan;
            hpoint(n).YData(:)=nan;
        end
        start=1;
        count=[1 1];
    end
uimenu(hm,'Label','Exit','Callback',@exitMC,'Separator','on')
    function exitMC(varargin)
        pauseMC();
        choice=questdlg('Are you sure?','Exit','yes','no','no');
        if strcmpi(choice,'yes')
            delete(fig);
        end
    end

end