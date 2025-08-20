% EllipseFit : Fit an ellipse to (x,y) data
% created 3/6/2005 by Daniel Dolan
%
% Usage:
% params = InterativeEllipseFit(x, y);          % use default guess
%        = InterativeEllipseFit(x, y, guess);   % user specified guess
%        = InterativeEllipseFit(x, y, fixed);   % hold some parameters fixed
%        = InterativeEllipseFit(x, y, fixed, options); % specify optimization parameters
% x and y are required for the function to operate.  If no guess value is
% given, the program generates a guess using DirectEllipseFit.  Fixed
% parameters may be set by specifying an array of ones and zeros, where
% ones correspond to fixed parameters.  For example, fixed=[1 1 0 0 0]
% implies that the x0 and y0 parameters are fixed during the optimization.
% The final argument, options, is a structure used by fminsearch.  See the
% documentation for optimset for more information.
%
% [params,fval,exitflag,output]=IterativeEllipseFit(...); % returns some
% extra information with params.  The residual error at the end of
% optimization is given by fval, the exit status by exitflag, and output
% data (# of iterations, etc.) by output.  See the documenation for
% fminsearch for more information.
%
function [params, fval, exitflag, output] = IterativeEllipseFit(x, y, ...
    guess, fixed, options)

% input checking
if nargin < 3
    guess = [];
end

if nargin < 4
    fixed = [];
end

if nargin < 5
    options = [];
end

% default values
if isempty(guess) 
    guess = DirectEllipseFit(x, y);
    fprintf('Calling direct fit...');
end

if isempty(fixed)
    fixed = zeros(size(guess));
end
if isnumeric(fixed)
    fixed = logical(fixed);
end
if numel(guess) ~= numel(fixed)
    error('Incompatible size for guess and fixed arrays');
end

if isempty(options)
    N = numel(guess) - sum(fixed); % number of adjustable parameters
    options = optimset('TolX', 1e-6, 'TolFun', 1e-6, 'MaxFunEvals', ...
        1000*N, 'MaxIter', 1000*N);
end

% convert data to column vectors
x = x(:);
y = y(:);

% setup variable and fixed parameter arrays
fixparam = guess(fixed);
varparam = guess(~fixed);

% Check if x is a double
% if ~isa(x, 'double')
%    x = double(x);
% end

% if ~isa(y, 'double')
%    y = double(y);
% end

varparam = double(varparam);

% fit ellipse to normalized data
[varparam, fval, exitflag, output] = fminsearch(...
    @Residual, varparam, options, x, y, fixparam, fixed);

% merge variable and fixed parameters
params = ParamMerge(varparam, fixparam, fixed);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func = Residual(varparam, x, y, fixparam, fixed)

param = ParamMerge(varparam, fixparam, fixed);
x0 = param(1);
y0 = param(2);
Ax = param(3);
Ay = param(4);
epsilon = param(5);

% physical parameter bounds
if (Ax <= 0)|(Ay <= 0)
    func = inf;
end

% conic parameters: boa=(b/a), etc...
boa = 2 * (Ax / Ay) * sin(epsilon);
coa = (Ax / Ay)^2;
doa = -2 * x0 - boa * y0;
eoa = -2 * coa * y0 - boa * x0;
foa = x0^2 + boa * x0 * y0 + coa * y0^2 - Ax^2 * cos(epsilon)^2;

func = x.^2 + boa * x .* y + coa * y.^2 + doa * x + eoa * y + foa;

%xn = (x - x0) / Ax;
%yn = (y - y0) / Ay;
%func= xn.^2 + 2 * xn.* yn * sin(epsilon) + yn.^2 - cos(epsilon)^2;

func = sum(func.^2) / numel(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% merge variable and fixed parameters in proper order
function func = ParamMerge(varparam, fixparam, fixed)

func = zeros(size(fixed));
ivar = 1;
ifix = 1;
for ii=1:length(fixed)
    if fixed(ii)
        func(ii) = fixparam(ifix);
        ifix = ifix + 1;
    else
        func(ii) = varparam(ivar);
        ivar = ivar + 1;
    end
end