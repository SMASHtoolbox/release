% trackLoop Loop progress tracking
%
% This function tracks progress in serial/parallel for loops, letting users
% know that a slow calculation is running. These reports may add several
% seconds to the total execution time, so this feature is not recommended
% for fast loops.
%
% An initial function call:
%    updateFcn=trackLoop(iterations);
% returns a function handle "updateFcn".  The integer input "iterations"
% defines the total number of loop iterations.  The function handle
% "update" returned by this function should be called at the end of each
% loop to increment loop progress.  Progress updates are displayed at 1%
% intervals.
%
% This function normally tracks progress in the command window, e.g.:
%Progress :  42%
% The default message "Progress : " can be changed by passing a third input
% argument.
%    updateFcn=trackLoop(iterations,message);
% The input "message" must be a character array; newline characters are
% permitted.  Progress reports can also be directed to a graphical dialog
% rather than the command window.
%    updateFcn=trackLoop(iterations,message,'dialog');
% Progress dialogs automatically close when the number of updates matches
% the specified number of iterations; manually closing the progress dialog
% *not* terminate the loop.  The command:
%   trackLoop('close');
% automatically closes all progress dialogs, including those leftover from
% premature loop termination.
%
% NOTE: this function requires MATLAB 2017a or later for tracking parallel
% loops.  Serial looping is always supported and used whenever no parallel pool
% exists, even if the Parallel Processing Toolbox is available.
%
% See also MUI
%

%
% created March 20, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function [updateFcn,db]=trackLoop(iterations,message,mode)

% manage input
assert(nargin > 0,'ERROR: insufficient input');

if strcmpi(iterations,'close')
    h=findall(groot,'Type','figure','Tag','trackLoopDialog');
    delete(h);
    return
end
assert(SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
    'ERROR: invalid number of iterations');

if (nargin < 2) || isempty(message)
    message='Progress : ';
else
    assert(ischar(message),'ERROR: invalid message');
end

ERRMSG='ERROR: invalid display mode';
if (nargin < 3) || isempty(mode)
    mode='console';
else
    assert(ischar(mode),ERRMSG);
    mode=lower(mode);
end
switch mode
    case {'console' 'dialog'}
    otherwise
        error(ERRMSG)
end

% start display
threshold=0.01;
switch mode
    case 'console'
        fprintf('%s',message);
        fprintf('  0%%');
        db=[];
    case 'dialog'
        db=SMASH.MUI.Waitbar(message,'Progress');       
        set(db.Handle,'Tag','trackLoopDialog');
        hCancel=findobj(db.Handle,'Type','uicontrol');
        delete(hCancel);
        drawnow();
end

% manage output
try % parallel mode
    DQ=parallel.pool.DataQueue();
    assert(~isempty(gcp));
    afterEach(DQ,@updateProgress);
    updateFcn=@updateParallel;

catch % serial mode
    updateFcn=@updateProgress;
end

    function updateParallel(varargin)
        send(DQ,[]);
    end

value=0;
LastUpdate=0;
    function updateProgress(varargin)
        value=value+1;
        if value >= iterations
            switch mode
                case 'console'
                    fprintf('\b\b\b\b100%%\n');
                case 'dialog'                  
                    delete(db);           
            end
            return
        end
        ratio=value/iterations;
        if (ratio-LastUpdate) > threshold
            switch mode
                case 'console'
                    fprintf('\b\b\b\b%3.0f%%',ratio*100);
                case 'dialog'
                    try
                        update(db,ratio);
                    catch
                    end
            end
            LastUpdate=ratio;
        end
    end

end