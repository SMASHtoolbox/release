% Waitbar class
%
% This class creates a custom wait bar for displaying the progress of a
% interative calculation.  To minimize the computational burden, the bar is
% only updated when the current state exceeds the previous state by some
% threshold.  By default, the wait bar is destroyed automatically when the
% progress reaches 100%.
% 
% The calling syntax of this class is:
%    >> w=Waitbar(message,name);
% where "message" is the text displayed above the wait bar and "name"
% appears in the figure title bar.  Both inputs are optional.  The current
% state of the bar is stored in the Progress, Done, and Cancel properties.
%
% See also SMASH.MUI, reset, update, increment
%

% creatd October 9, 2013 by Daniel Dolan (Sandia National Laboratories)
classdef Waitbar < handle
    %%
    properties (SetAccess=protected)
        Progress=0 % Calculation progress
        Bar=0 % Bar progress
    end
    properties
        Threshold=0.01 % Bar update threshold
        AutoClose=false % Close when bar reaches 100%
    end
    properties (SetAccess=protected)
        Handle % Graphic handle
        Done=false % Wait complete
        Cancel=false % Wait canceled
    end
    %%
    methods (Hidden=true)
        function object=Waitbar(message,name)
            % handle input
            if (nargin<1) || isempty(message)
                message='Working...';
            end
            if nargin<2
                name='';
            end
            % create wait bar and store object inside
            object.Handle=waitbar(0,message,'Name',name,'Name',name,...
                'CreateCancelBtn',@CancelWait);
            setappdata(object.Handle,'Object',object);
        end
    end
    methods
        function delete(object)
            delete(object.Handle);
        end
        function set.Threshold(object,value)
            if isnumeric(value) && numel(value==1) && (value>0) && (value<1)
                object.Threshold=value;
            else
                error('ERROR: invalid Threshold setting');
            end
        end
        function set.AutoClose(object,value)
            if islogical(value) && numel(value)==1
                object.AutoClose=value;
            else
                error('ERROR: invalid AutoClose setting');
            end
        end
    end
end