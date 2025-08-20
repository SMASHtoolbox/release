% SMOOTH Smooth Signal Data
%
% This method smooths the Data array in Signal objects, removing high
% frequency content.  The general calling syntax is:
%     object=smooth(object,choice,value);
% Three smoothing choices are supported.
%    -'mean' performs local averaging.  Value specifies full width.
%    -'polynomial' uses Savitzky-Golay coefficients.  Value specifies
%    the order and number of points (full width).
%    -'kernel' uses value as a convolution kernel.
% The last choice enables a variety of customizable operations to be
% performed.  For example, an approximate numerical derivative can be
% calculated as:
%     derivative=smooth(object,'kernel',[-1 0 +1]/(2*h));
% where h the grid spacing.  Another example, DC removal, is show below.
%     kernel=[0 0 0 1 0 0 0]-repmat(1/7,[1 7]);
%     new=smooth(object,'kernel',kernel);
%
% See also Signal, sharpen
%

%
% created October 5, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=smooth(object,choice,value)

% verify uniform grid
object=makeGridUniform(object);

% handle input
assert(nargin>=3,'ERROR: smoothing choice and value are required');

% apply smoothing choice
switch lower(choice)
    case 'mean'
        if ~isscalar(value) || (round(value)~=value) || (value<1)
            error('ERROR: invalid mean filter parameter');
        end
        kernel=ones(value,1);
        kernel=kernel(:)/sum(kernel);
        object=smooth(object,'kernel',kernel);
    case 'kernel'
        kernel=value(:);
        if size(object.Data,1)==1
            kernel=transpose(kernel);        
        end        
        data=conv2(object.Data,kernel,'same');
        object.Data=reshape(data,size(object.Data));
    case 'polynomial'        
        object.Data=SGderivative(0,value,object.Data,object.Grid);
    otherwise
        error('ERROR: invalid smoothing choice');
end

object=updateHistory(object);

end