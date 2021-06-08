% EllipseFit : Fit an ellipse to (x,y) data
% Created 8/2/2004 by Daniel Dolan
%
function func = EllipseFit(params, x, y, fixed, options)

if nargin < 4
    fixed = [];
end
if isempty(fixed)
    %fixed = logical(zeros(size(params)));
    fixed=true(size(params));
end

if nargin < 5
    options = [];
end
if isempty(options)
    options = optimset();
end


varparams = [];
varlabels = {};
fixedparams = [];
fixedlabels = {};
ivar = 1;
ifixed = 1;

x0 = params(1);
if logical(fixed(1))
   fixedparams(ifixed) = x0;
   fixedlabels{ifixed} = 'x0';
   ifixed = ifixed + 1;
else
    varparams(ivar) = x0;
    varlabels{ivar} = 'x0';
    ivar = ivar + 1;
end

y0 = params(2);
if logical(fixed(2))
   fixedparams(ifixed) = y0;
   fixedlabels{ifixed} = 'y0';
   ifixed = ifixed + 1;
else
    varparams(ivar) = y0;
    varlabels{ivar} = 'y0';
    ivar = ivar + 1;
end

Lx = params(3);
if logical(fixed(3))
   fixedparams(ifixed) = Lx;
   fixedlabels{ifixed} = 'Lx';
   ifixed = ifixed + 1;
else
    varparams(ivar) = Lx;
    varlabels{ivar} = 'Lx';
    ivar = ivar + 1;
end

Ly = params(4);
if logical(fixed(4))
   fixedparams(ifixed) = Ly;
   fixedlabels{ifixed} = 'Ly';
   ifixed = ifixed + 1;
else
    varparams(ivar) = Ly;
    varlabels{ivar} = 'Ly';
    ivar = ivar + 1;
end

phase=params(5);
if logical(fixed(5))
   fixedparams(ifixed) = phase;
   fixedlabels{ifixed} = 'phase';
   ifixed = ifixed + 1;
else
    varparams(ivar) = phase;
    varlabels{ivar} = 'phase';
    ivar = ivar + 1;
end

varparams = fminsearch(...
    @Residuals, varparams, options, x, y, varlabels, fixedparams, ...
    fixedlabels);

ivar = 1;
ifixed = 1;
for ii=1:length(params)
    if logical(fixed(ii))
        func(ii) = fixedparams(ifixed);
        ifixed = ifixed + 1;
    else
        func(ii) = varparams(ivar);
        ivar = ivar+1;
    end    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func = Residuals(varparams, x, y, varlabels, fixedparams, ...
    fixedlabels)

for ii=1:length(varparams)
    switch(varlabels{ii})
        case 'x0'
            x0 = varparams(ii);
        case 'y0'
            y0 = varparams(ii);
        case 'Lx'
            Lx = varparams(ii);
        case 'Ly'
            Ly = varparams(ii);
        case 'phase'
            phase = varparams(ii);
        otherwise
            %
    end    
end

for ii=1:length(fixedparams)
    switch(fixedlabels{ii})
        case 'x0'
            x0 = fixedparams(ii);
        case 'y0'
            y0 = fixedparams(ii);
        case 'Lx'
            Lx = fixedparams(ii);
        case 'Ly'
            Ly = fixedparams(ii);
        case 'phase'
            phase = fixedparams(ii);
        otherwise
            %
    end    
end

x = x - x0;
y = y - y0;
Ax = 1 / Lx;
Ay = 1 / Ly;
C = sin(phase);

func = Ax^2 * (x.^2) + Ay^2 * (y.^2) + 2 * (Ax * x) .* (Ay * y) * C + C.^2 - 1;
func = func.^2;
%plot(func);figure(gcf);waitforbuttonpress;
func = sum(func);