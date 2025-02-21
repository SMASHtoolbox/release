% scaleBasis Scale basis functions
%
% This *protected* method scales basis functions for all defined sinusoids.
%    scaleBasis(object);
% Matrix techniques are used to determine amplitude and phase best suited
% to the current frequency settings.
%
% See also SinusoidFit, optimize
%

%
% created February 25, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=scaleBasis(object)

if object.NumberSinusoids == 0
    full=split(object.Spectrum,1);
    full=full.Data;
    object.Spectrum=reset(object.Spectrum,[],[full full]);
    return
end

% general setup
sinc=@(in) SMASH.SignalAnalysis.sinc(in,'normalized');
full=split(object.Spectrum,1);
N=object.NumberSinusoids;

f=full.Grid;
M=numel(f);

% real and imaginary components
matrixA=nan(M,N);
matrixB=nan(M,N);
for n=1:N
    f0=object.Parameter(n,1);
    arg1=(f-f0)*object.Duration;
    arg2=(f+f0)*object.Duration;
    vectorA=(...
        +(sinc(arg1)+sinc(arg2))/2 ...
        +(sinc(arg1-1)+sinc(arg2-1))/4 ...
        +(sinc(arg1+1)+sinc(arg2+1))/4);
    vectorB=(...
        +(sinc(arg1)-sinc(arg2))/2 ...
        +(sinc(arg1-1)-sinc(arg2-1))/4 ...
        +(sinc(arg1+1)-sinc(arg2+1))/4);
    scale=(1)/(2*trapz(f,vectorA.^2+vectorB.^2));
    scale=sqrt(scale);    
    matrixA(:,n)=vectorA*scale;   
    matrixB(:,n)=vectorB*scale;
end

[A,~]=linsolve(matrixA,real(full.Data));
xfit=matrixA*A;
[B,~]=linsolve(matrixB,imag(full.Data));
yfit=matrixB*B;
fit=xfit+1i*yfit;
remainder=full.Data-fit;

object.Spectrum=reset(object.Spectrum,[],[full.Data remainder]);
Q=A(:)+1i*B(:);
object.Parameter(:,2)=abs(Q);
object.Parameter(:,3)=angle(Q);

% manage output
if nargout > 0
    varargout{1}=fit;
end

end