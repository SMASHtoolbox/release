% UNDER CONSTRUCTION

function value=getPosition()

master=getMaster();
x0=master.getX();
y0=master.getY();

temp=master.getSize();
Lx=temp.getWidth();
Ly=temp.getHeight();

pos=get(groot,'ScreenSize');
y0=pos(4)-y0-Ly;
value=[x0 y0 Lx Ly];

end