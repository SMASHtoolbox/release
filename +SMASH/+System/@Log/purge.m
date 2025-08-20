% purge Purge log entries
%
% This method purges messages from one or more log targets.
%    purge(object);
% Log files and list boxes are automatically purged by default, leaving the
% command window untouched.  
%
% Specific log types can be purged with additional input arguments.
%    purge(object,target,...);
% Valid target names include:
%   -'file' purges all log files.
%   -'control' purges all list boxes.
%   -'window' purges the command window.  WARNING: this removes *all*
%   statements and output messages!
%   -'all' purges all logs.
%
% See also Log, write
% 

% 
% created October 21, 2018 by Daniel Dolan (Sandia National Laboratories) 
%
function purge(object,varargin)

% mange input
if nargin < 2
    varargin{1}='file';
    varargin{2}='control';
end

mode.File=false;
mode.Control=false;
mode.Window=false;
for n=1:numel(varargin)
    assert(ischar(varargin{n}),'ERROR: invalid purge code');
    switch lower(varargin{n})
        case 'file'
            mode.File=true;
        case 'control'
            mode.Control=true;
        case 'window'
            mode.Window=true;
        case 'all'
            mode.File=true;
            mode.Control=true;
            mode.Window=true;
        otherwise
            error('ERROR: invalid purge code');
    end
end

% purge requested logs
for m=1:numel(object.Target)
    target=object.Target{m};
    if ishghandle(target)
        if mode.Control
            for n=1:numel(target)
                set(target(n),'String','','Value',1);
            end
        end
    elseif strcmp(target,'-stdout') || strcmp(target,'-stderr')
        if mode.Window
            clc();
        end
    elseif ischar(target)
        if mode.File
            try
                fid=fopen(target,'w');
                fclose(fid);
            catch
                generateWarning(object,'Cannot open log file:\n   %s',...
                    target);
            end
        end
    end
end

end