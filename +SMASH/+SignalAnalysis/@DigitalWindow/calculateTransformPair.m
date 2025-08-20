% calculateTransformPair Window transform and conjugate
%
% This method calculates the frequency transform and its conjugate
% function.
%    [transform,frequency]=calculateTransformPair(object);
% The output "transform" is a complex array at the locations specified by
% the output "frequency"; the latter runs from -1/2 to +1/2.  The real part
% of "transform" is the Fourier transform of the window function, while the
% imaginary part is the conjugate function
%
% See also DigitalWindow, tabulate
%
function varargout=calculateTransformPair(object)

[raw,frequency]=fft(object,[],'full');
X=real(raw);
temp=SMASH.SignalAnalysis.Signal(frequency,X);
temp=hilbert(temp);
Y=imag(temp.Data);
Y=Y*sqrt(trapz(frequency,X.^2)/trapz(frequency,Y.^2));

transform=X+1i*Y;

% manage output
if nargout == 0
    figure();
    plot(frequency,real(transform),frequency,imag(transform));
    xlabel('Normalized frequency');
    ylabel('Transform amplitude');
    legend('Window','Conjugate')  
    title(object.Name,'FontWeight','normal');
    return
end

varargout{1}=transform;
varargout{2}=frequency;

end