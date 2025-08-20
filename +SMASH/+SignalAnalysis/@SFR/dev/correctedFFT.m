% private function 
function [transform,fn]=correctedFFT(signal,N2,mode)

persistent previous
if isempty(previous) || (previous.N2 ~= N2)
    previous.N2=N2;
    temp=((-N2/2):(N2/2-1))/N2;
    previous.Full=temp(:);
    temp=(0:N2/2)/N2;
    previous.Positive=temp(:);
end

N=numel(signal);
transform=fft(signal,N2)/sqrt(N);
switch mode
    case 'full'
        transform=fftshift(transform);
        fn=previous.Full;
    case 'positive'
        M=N2/2+1;
        transform=transform(1:M);
        fn=previous.Positive;
end
correction=exp(1i*pi*fn*(N-1));
transform=transform(:).*correction(:);

end