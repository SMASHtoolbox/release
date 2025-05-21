% transfer Apply transfer function
%
% This method applies a user specified transfer function to a Signal
% object.
%    new=transfer(object,myfunc);
% The input "myfunc" is a handle to a function that accepts one input and
% returns one output of the same size.  For example:
%    myfunc=@(f) 1./(1+2i*pi*f*tau)
% describes a first-order low pass filter, where tau is the characteristic
% smoothing time.
%
% By default, this method returns the real part of the transformed
% Signal.  Many times the result should be real mathematically, but small
% imaginary components may persist due to round off error.  This behavior
% can be modified with an additional input.
%    new=transfer(object,myfunc,'real');    % default behavior
%    new=transfer(object,myfunc,'imag');    % imaginary part only
%    new=transfer(object,myfunc,'complex'); % full transform
%
% See also Signal
%

%
% created February 23, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=transfer(object,target,mode)

% manage input
assert(nargin >= 2,'ERROR: invalid number of inputs');
switch class(target)
    case 'function_handle'
        % continue
    case 'char'
        target=str2func(target);
    otherwise
        error('ERROR: invalid target function');
end

if (nargin<3) || isempty(mode)
    mode='real';
end
assert(ischar(mode),'ERROR: invalid transform mode');
mode=lower(mode);
switch mode
    case 'real'
        % continue
    case 'complex'
        % continue
    case {'imag' 'imaginary'}
        mode='imag';
    otherwise
        error('ERROR: invalid transform mode');
end

% enforce uniform grid
[object,spacing]=verifyGrid(object);

% evaluate transfer function
N=numel(object.Grid);
N2=pow2(nextpow2(N));

frequency=[0:N2/2 -(N2/2-1):-1];
frequency=frequency/(N2*spacing);

try
    transfer=target(frequency);
catch ME
    rethrow(ME);
end

% perform transfer in the frequency domain, then transform back
data=fft(object.Data,N2);
transfer=reshape(transfer,size(data));
data=data.*transfer;
data=ifft(data);
data=data(1:N);

switch mode
    case 'real'
        data=real(data);
    case 'imag'
        data=imag(data);
end
object.Data=data;

end