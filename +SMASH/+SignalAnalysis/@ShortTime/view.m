% view View object
%
% This method displays the Measurement in a ShortTime object.
%    view(object);
%
% See also SMASH.SignalAnalysis.ShortTime
%

%
% created June 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=view(object,varargin)

if nargout==0
    view(object.Measurement,varargin{:});
else
    varargout=cell(1,nargout);
    [varargout{:}]=view(object.Measurement,varargin{:});
end

end