%% generate peak data
x=linspace(0,1,25);
x0=0.6;
sigma=0.2;
y=exp(-(x-x0).^2/(2*sigma^2))+0.10*randn(size(x));
data=[x(:) y(:)];

%%
report=SMASH.Velocimetry.PDV.findPeak(data,'Mode','centroid');
fprintf('Centroid results:\n');
disp(report)

%%
report=SMASH.Velocimetry.PDV.findPeak(data,'Mode','maximum');
fprintf('Maximum results:\n');
disp(report)

%% 
report=SMASH.Velocimetry.PDV.findPeak(data,'Mode','parabola');
fprintf('Parabola results:\n');
disp(report)

%% 
report=SMASH.Velocimetry.PDV.findPeak(data,'Mode','gaussian');
fprintf('Parabola results:\n');
disp(report)