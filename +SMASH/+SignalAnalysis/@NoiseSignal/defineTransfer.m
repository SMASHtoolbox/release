% defineTransfer Define system transfer function
%
% This method defines the transfer function for the noise system.
%    object=defineTransfer(object,type,value);
% Several transfer types are supported.
%    -'nyquist' transfers all frequencies equally up to a specified
%    fraction of the Nyquist frequency; higher frequencies are completely
%    omitted.  The input "value" must be greater than zero and less than or
%    equal to one (default value).
%    -'bandwidth' transfers all frequencies equally up to a specified
%    frequency cutoff.  The bandwidth frequency must be greater than zero.
%    -'table' defines a tabular transfer table. The first column of this
%    table specifies frequency values and the second column specifies
%    transfer values at these frequencies.  Transfer tables are passed
%    through the input "value".
%    -'function' defines the system transfer by a
%    user-specified function handle.  This function must accept an array of
%    frequency values and return an array of transfer values (of the same
%    size).
% The default transfer type is 'nyquist'
%
% See also NoiseSignal, generate
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=defineTransfer(object,type,value)

% manage input
if (nargin<2) || isempty(type)
    type='nyquist';
end
assert(ischar(type),'ERROR: invalid transfer type');

if nargin<3
    value=[];
end

% generate table
frequency=object.ReciprocalGrid;
transfer=zeros(size(frequency));
switch lower(type)
    case 'nyquist'
        if isempty(value)
            value=1;
        end
        assert(isscalar(value) && (value>0) && (value<=1),...
            'ERROR: invalid fraction value');
        index=(abs(frequency) <= (object.NyquistValue*value));
        transfer(index)=1;
    case 'bandwidth'
        assert(isscalar(value) && (value>0),...
            'ERROR: invalid bandwidth value');
        index=(abs(frequency) <= value);
        transfer(index)=1;
    case 'table'
        assert(size(value,2)==2,...
            'ERROR: invalid transfer table');
        frequency=value(:,1);
        transfer=value(:,2);
        temp=interp1(frequency,transfer,[0 object.NyquistValue]);
        assert(~any(isnan(temp)),...
            'ERROR: transfer table does not span the complete frequency range');
    case 'function'
        if ischar(value)
            value=str2func(value);
        end
        assert(isa(value,'function_handle'),'ERROR: invalid transfer function');
        frequency=object.ReciprocalGrid;
        transfer=value(frequency);
    otherwise
        error('ERROR: invalid transfer mode');
end
object.TransferTable=[frequency transfer];
object.TransferTable=sortrows(object.TransferTable,1);

end