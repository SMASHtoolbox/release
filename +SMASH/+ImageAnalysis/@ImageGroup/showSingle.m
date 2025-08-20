% SHOWSINGLE View single image of ImageGroup Data
%
% This method opens the indicated individual Image from the
% provided ImageGroup in a separate window.
%
%   showSingle(object,ImageNumber);
% 
% See also ImageGroup, view, showMosaic
%

%
% created January 12, 2016 by Sean Grant (Sandia National Laboratories/UT)
%
function varargout=showSingle(object,frameNumber,varargin)

% handle inputs
if(nargin<3)
    target=[];
else
    target=varargin{1};
end

if(nargin<2) % No frameNumber given, default to frame 1.
    temp=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,1));
else
    assert(rem(frameNumber,1)==0,'Frame slection must be an integer')
    assert(1<=frameNumber&&frameNumber<=object.NumberImages,'Invalid Image number selection')
    temp=SMASH.ImageAnalysis.Image(object.Grid1,object.Grid2,object.Data(:,:,frameNumber));
end

% Handle output
if nargout>=1
    varargout{1}=view(temp,'show',target);
else
    view(temp,'show',target);
end

end
