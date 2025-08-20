% AxesArray : create a continuous array of axes
%
% This function is similar to the subplot command with the exception that
% all axes touch the adjacent neighbor.  This is convenient when many
% different plots need to be displayed with the same axis settings.
% Axes handles are returned as output to allow the user to address specific
% axes.  Some manual tweaking of tick marks may be necessary as the outer
% limits of adjacent axes can overlap.
% 
% Usage:
%>>ha=AxesArray; % creates a 2 X 2 axes array, returns handles as ha
%>> ha=AxesArray(M,N); % create a M X N array.
% 
% Specific axes accessible by handle:
%>>axes(ha(3)); % access the third axes
% Axes numbers increase from left to right (similar to subplot).  
%For example, the third axes of a 2 X 2 array is on the bottom-left corner
% of the the figure.
%
% created 7/14/2005 by Daniel Dolan
function ha=AxesArray(M,N)

% input check
if nargin<1
    M=[];
end
if nargin<2
    N=[];
end

% default settings
if isempty(M)
    M=2;
end
if isempty(N)
    N=2;
end

% prepare figure
clf;

% determine default axes size
axes;
pos=get(gca,'Position');

Ly=pos(4)/M;
Lx=pos(3)/N;
x0=pos(1);
y0=pos(2);

delete(gca);

% create axes
ha=nan(M,N);
for ii=1:M
    yk=y0+(M-ii)*Ly;
    xk=x0;
    for jj=1:N
        ha(ii,jj)=axes('Position',[xk yk Lx Ly],'Box','on',...
            'XTickLabel','','XTickLabelMode','manual',...
            'YTickLabel','','YTickLabelMode','manual');
        if jj==1
            set(ha(ii,jj),'YTickLabelMode','auto');
        end
        if ii==M
            set(ha(ii,jj),'XTickLabelMode','auto');
        end
        xk=xk+Lx;  
    end
end

% link axis limits
linkaxes(ha);