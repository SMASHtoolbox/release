% Collection Data file collection class
%
% This class manages of data files with a shared name pattern in a common
% location.  By default:
%    obj=Collection();
% every data file in the current directory supported by the FileAccess
% package is part of the collection.  The Location, Pattern, and Format
% properties control collection membership.  For example:
%    obj.Pattern='data*.h5';
%    obj.Format='keysight';
% restricts the collection to Keysight digitizer files to names beginning
% with 'data'.
%
% The formal identification process is as follows.
%    1. Find all *potential* collection files by combining the specified
%    Location/Pattern in the the dir command.
%    2. Sweep through the candidate and find the *first* data format able
%    to probe each file.  Retain only successful format matches.
%    3. Associate each match with all specified Record values. Empty values
%    are used as a placeholder for single-record files and the default
%    record (where supported) for multi-record files.
% For example:
%    obj.Pattern='data*.h5';
%    obj.Format='keysight';
%    object.Record=2;
% indicates a collection based on the second record of Keysight digitizer
% files; the preceding example would default to the first record.  Record
% labels may be integers or character arrays, depending on the data format.
%
% NOTE: file identification can be *very* slow if all supported data
% formats are used.  For best results, the Format propery should be
% restricted to plausible values for the data of interest.
%
%
% See also SMASH.FileAccess, SMASH.FileAccess.SupportedFormats, dir
% 
classdef Collection
    %% file location and prefix
    properties
        % Location Data file location
        %
        % This property controls where collection files are located, which
        % by default is the current directory.  
        %
        % See also Collection
        Location
        % Pattern Data file pattern
        %
        % This property controls the name pattern that identifies
        % collection files.  The default value is all files ('*'), and
        % wildcards are permitted.
        %
        % See also Collection
        Pattern   = '*'
        % Format Data file format(s)
        %
        % This property controls the data formats used to identify
        % collection files.  The default value is all formats supported by
        % the FileAcess package.  Character arrays, strings, and cell
        % arrays may be specified.
        %
        % See also Collection
        Format
        % Record Data file record(s)
        %
        % This property controls the record number(s)/label(s) used to read
        % collection data.  Not all data formats utilize records, so this
        % property may be left empty in many situations.  
        %
        % See also Collection
        Record = []
    end
    methods
        function object=set.Location(object,value)
            if isempty(value)
                value='.';            
            elseif isstring(value) && isscalar(value)
                value=char(value);
            else
                assert(ischar(value),'ERROR: invalid file location');
            end
            index=(value == '/') | (value == '\');
            value(index)=filesep;
            assert(isfolder(value),'ERROR: invalid file location');
            if value(end) ~= filesep
                value(end+1)=filesep;
            end   
            object.Location=value;
        end
        function object=set.Pattern(object,value)
            if isempty(value)
                value='*';
            else
                try
                    [~]=dir(value);
                catch
                    error('ERROR: invalid file pattern');
                end
            end
            object.Pattern=value;
        end
        function object=set.Record(object,value)
            if isnumeric(value)
                new=cell(size(value));
                for k=1:numel(value)
                    new{k}=value(k);
                end
                value=new;
            elseif ischar(value)
                value={value};
            elseif isstring(value) || iscellstr(value)
                value=cellstr(value);
            else
                error('ERROR: invalid record setting');
            end
            object.Record=value;
        end
        function object=set.Format(object,value)
            persistent valid
            if isempty(valid)
                valid=SMASH.FileAccess.SupportedFormats();
            end
            if isempty(value)
                object.Format=valid;
                return
            end
            if ischar(value)
                value={value};
            else
                assert(iscellstr(value) || isstring(value),...
                    'ERROR: invalid format')
                value=cellstr(value);
            end
            for m=1:numel(value)
            match=false;
            for n=1:numel(valid)
                if strcmp(value{m},valid{n})
                    match=true;
                    break
                end
            end
            assert(match,'ERROR: unsupported file format');
            end
            object.Format=value;
        end   
    end    
    %% constructor
    methods (Hidden=true)
        function object=Collection(varargin)
            object.Location='';
            object.Format='';
        end
    end
    %%
    methods (Static=true)
        varargout=renamePattern(varargin)
        varargout=generateArray(varargin)
    end
end