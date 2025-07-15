% DirectEllipseFit : direct ellipse fitting
% created 4/5/2005 by Daniel Dolan
%
% Usage:
% params=DirectEllipseFit(x,y);
%
% This function provides a direct (non-iterative) ellipse fit for a series
% of (x,y) data.  The core opertion of the function is based on the MATLAB
% routines listed in a conference paper by Halir and Flusser (BibTeX entry
% listed below.  The only differnece between this function is some minor
% input checking and the calculation of parametric ellipse parameters.
%
%@inproceedings{HalirCGV1998,
%   Author = {Halir, R. and Flusser, J.},
%   Title = {Numerically stable direct least squares fitting of ellipses},
%   BookTitle = {6th International Conference on Computer Graphics and Visualization},
%   Editor = {Skala, V.},
%   Address= {Plzen, Czech Republic},
%   Publisher = {University of West Bohemia Press},
%   Volume = {1},
%   Pages = {125-132},
%   Year = {1998} }
%
function [params1,params2]=DirectEllipseFit(x,y)

% input checking
if nargin<2
    error('x and y data input is needed!');
end
if numel(x)~=numel(y)
    error('Incompatible data: x and y have same number of elements');
end

% define default output
[params1,params2]=deal(repmat(nan,[1 6]));

% ensure column data vectors
x=x(:);
y=y(:);

% verbatim from Halier and Flusser
try
D1 = [x .^ 2, x .* y, y .^ 2]; % quadratic part of the design matrix
D2 = [x, y, ones(size(x))]; % linear part of the design matrix 
S1 = D1' * D1; % quadratic part of the scatter matrix 
S2 = D1' * D2; % combined part of the scatter matrix 
S3 = D2' * D2; % linear part of the scatter matrix 
T = - inv(S3) * S2'; % for getting a2 from a1 
M = S1 + S2 * T; % reduced scatter matrix 
M = [M(3, :) ./ 2; - M(2, :); M(1, :) ./ 2]; % premultiply by inv(C1) 
[evec, eval] = eig(M); % solve eigensystem 
cond = 4 * evec(1, :) .* evec(3, :) - evec(2, :) .^ 2; % evaluate aÕCa 
a1 = evec(:, find(cond > 0)); % eigenvector for min. pos. eigenvalue 
catch
    return
end

if isempty(a1) || ~isreal(cond)
    return
end
a = [a1; T * a1]; % ellipse coefficients 

% sign check
if (a(1)<0) || (a(3)<0)
    a=-a;
end

% define specific parameter variables for clarity
params2=a;
%params2=params2/params2(1);
%params2=params2/params2(1);
f=params2(6);
e=params2(5);
d=params2(4);
c=params2(3);
b=params2(2);
a=params2(1);
discrim=b^2-4*a*c;
if discrim>=0
    error('This is NOT an ellipse');
end

% conversion to parametric ellipse parameters
epsilon=asin(b/sqrt(4*a*c));

x0=-(e*b-2*c*d)/discrim;
y0=-(b*d-2*a*e)/discrim;

Ax=sec(epsilon)*sqrt(x0^2+(b/a)*x0*y0+(c/a)*y0^2-(f/a));
Ay=sec(epsilon)*sqrt((a/c)*x0^2+(b/c)*x0*y0+y0^2-(f/c));

params1=[x0 y0 Ax Ay epsilon];