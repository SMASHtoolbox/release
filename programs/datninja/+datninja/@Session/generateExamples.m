%    generateExamples();
function generateExamples(varargin)

if regexp(pwd,smashroot)
    error('ERROR: cannot generate examples in the SMASH toolbox directory');
end


% linear
fig=figure();
x=1:9;
y=1:9;
plot(x,y,'ko');
xlim([0 10]);
ylim([0 10]);
xlabel('X axis');
ylabel('Y axis');
generate(fig,10,'LinearExample.png');
close(fig);

% log x
fig=figure();
x=10.^(-4:4);
y=1:9;
plot(x,y,'ko');
set(gca,'XScale','log');
xlabel('X axis');
ylabel('Y axis');
generate(fig,2,'LogxExample.png');
close(fig);

% log y
fig=figure();
x=1:9;
y=10.^(-4:4);
plot(x,y,'ko');
set(gca,'YScale','log');
xlabel('X axis');
ylabel('Y axis');
generate(fig,2,'LogyExample.png');
close(fig);

% log xy
fig=figure();
x=10.^(-4:4);
y=10.^(-4:4);
plot(x,y,'ko');
set(gca,'XScale','log','YScale','log');
xlabel('X axis');
ylabel('Y axis');
generate(fig,-2,'LogxyExample.png');
close(fig);

end

function generate(fig,theta,name)

local=[tempname() '.png'];
print(fig,'-dpng',local);

obj=SMASH.ImageAnalysis.Image(local,'graphics');
obj=rotate(obj,theta);
temp=obj.Data;
temp(isnan(temp))=max(temp(:));

new=figure();
imagesc(temp);
colormap gray
axis image
axis off
set(gca,'Position',[0 0 1 1]);
pos=getpixelposition(new);
pos(3)=numel(obj.Grid1);
pos(4)=numel(obj.Grid2);
setpixelposition(new,pos);

print(new,'-dpng',name);
close(new);

end