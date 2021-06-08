% This class provides interactive selection of files and directories,
% unifying capaiblities found in MATLAB's uigetfile, uiputfile, and
% uigetdir functions.  This class does *not* invoke system-dependent dialog
% boxes, so the user experience is more uniform across software platforms.
% The class also provides more customization options than the built-in
% functions.
%
% Begin by creating a SelectFile object.
%    sf=SelectFile(); % default options
%    sf=SelectFile(option,value,...); % custom options
% Interface options can be set during (as show above) or after object creation.
%    sf.(option)=value;
% The "launch" method creates the file selection interface and waits for
% user input.
%    name=launch(sf);
% The appearance of this interface can be adjusted with general options,
% filter options, file options, and selection options.
%
% General options:
%    -'Title' specifies the text label shown at the top of the selection
%    dialog.
%    -'Location' indicates interface placement ('center', 'north', etc.)
%    relative to the 'Reference' object (usually another figure).
%    -'StartDir' controls the starting directory for the interface.  The
%    default value is the current directory.
%
% Filter options:
%    -'Filter' restricts file display to items that match a pattern (wild
%    cards permitted).
%    -'EnableFilter' indicates whether filtering should be used or not.
%    -'FilterControl' specifies if filter controls should be displayed.
%
% File options:
%    'FileLabel' controls the label placed above the file list.
%    'ShowHidden' allows hidden files/directories to be displayed
%    'HiddenControl' specifies if the hidden control should be displayed.
%    'FileControls' specifies if files controls (new/delete/rename) should be displayed.
%    'NewFunction' defines an error-checking function called when new files are created.
%    'DeleteFunction' defines an error-checking function called when files are deleted.
%
% Selection options:
%    'MultipleSelection' allows/prohibits multiple file selection.
%    'ShowPath' shows complete paths for selected files 
%
% See also MUI
%

%
% created November 2, 2016 by Daniel Dolan (Sandia National Laboratories)
%
classdef SelectFile
    %%
    properties
        Title = 'Select file' % Dialog title
        Location = 'center' % Dialog position
        Reference % Reference object for positioning
        StartDir = '' % Starting directory        
        %
        Filter = '' % File name filter
        EnableFilter=true % Enable/disable filter
        FilterControl = 'on' % Display filter controls
        %
        FileLabel='Directory files:' % File list label
        ShowHidden=false % Show hidden files
        HiddenControl='on' % Enable hidden file control
        FileControls = 'on' % Display file controls
        NewFunction = '' % Error checking for file creation
        DeleteFunction = '' % Error checking for file deletion
        %                      
        MultipleSelection = false % Control single/multiple selection mode
        ShowPath = false % Show/hide complete paths in multiple selection mode
    end
    %%
    methods (Hidden=true)
        function object=SelectFile(varargin)
            % manage input
            assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');
            for n=1:2:nargin
                if isprop(object,varargin{n})
                    object.(varargin{n})=varargin{n+1};
                end
            end            
        end
    end
    %% setters
    
end