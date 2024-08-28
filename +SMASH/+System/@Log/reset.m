% reset Reset log target(s)
%
% This method resets the list of targets where log messages are sent.
%    reset(object,target1,...);
% Valid targets include:
%    -'-stdout' and '-stderr' for the command window
%    -Text file names
%    -List box handles
% The default target, if none are specified, is '-stdout'.
%
% See also Log
%

%
% created October 22, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function reset(object,varargin)

% manage input
if nargin < 2
    varargin{1}='-stdout';
end

% error checking
for m=1:numel(varargin)
    if ishghandle(varargin{m})
        for n=1:numel(varargin{m})
            temp=get(varargin{m},'Style');
            assert(strcmpi(temp,'listbox'),...
                'ERROR: cannot log statements to %s objects',temp);
        end
    elseif strcmpi(varargin{m},'-stdout') || strcmpi(varargin{m},'-stderr')
        varargin{m}=lower(varargin{m});
    elseif ischar(varargin{m})
        assert(SMASH.System.verifyFileName(varargin{m}),...
            'ERROR: invalid file name');
    end
end

% store targets
object.Target=varargin;

end