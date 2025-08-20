% This class creates and manages Sandia Data Archive (*.sda) files.
% Various types of information can be written to and read from these files
% across any platform that supports HDF5.
%
% Archive objects are created by specifying a file name.
%   >> archive=SDAfile(filename);
% The file *must* have the extension '*.sda' (upper or lower case).  If
% does not exist, it is created and filled with status information.
% Existing files can be opened in "append" or "overwrite" mode with a
% second input argument.
%   >> archive=SDAfile(filename,'append'); % default mode
%   >> archive=SDAfile(filename,'overwrite');
% Append mode is chosen by default and allows new information to be added
% to information already present in the archive.  Overwrite mode removes
% all information from an existing file.
%
% Information from MATLAB can be inserted into or extracted from an
% archive.
%    >> insert(archive,label,data) % MATLAB to archive file
%    >> data=extract(archive,label); % archive file to MATLAB
% The argument "label" is a unique character array that is used to track
% information.
%
% External files can imported to the archive:
%    >> import(archive,label,file); % external file to archive file
% or exported from the archive.
%    >> export(archive,label,file); % archive file to external file
%
% The "probe" method displays the current state of the archive file.  The
% "select" method allows specific records to be selected interactively.
%

% created October 8, 2013 by Tommy Ao (Sandia National Laboratories)
% revised October 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%    -altered method to match revised SDA specification
% revised April 4, 2016 by Daniel Dolan
%    -format version updated to 1.0
classdef SDAfile
    %%
    properties (SetAccess=immutable)
        ArchiveFile % File (*.sda) linked to archive        
    end
    properties       
        Writable % Write access ('yes' or 'no')
    end
    %%
    methods (Hidden=true)
        function object=SDAfile(filename,mode,verbose)
            % handle input
            assert(nargin>=1,'ERROR: no archive file specified');
            if (nargin<2) || isempty(mode)
                mode='create';
            end
            if (nargin<3) || isempty(verbose)
                verbose='quiet';
            end
            switch verbose
                case {true,'verbose','v'}
                    verbose=true;
                case {false,'quiet','q'}
                    verbose=false;
            end
            % test filename
            [pathname,filename,ext]=fileparts(filename);
            assert(strcmpi(ext,'.sda'),'ERROR: non-SDA file specified');            
            if isempty(pathname)
                pathname=pwd;
            else
                current=pwd;
                cd(pathname);
                pathname=pwd;
                cd(current);
            end
            filename=fullfile(pathname,[filename ext]);
            object.ArchiveFile=filename;
            if exist(filename,'file') 
                switch mode
                    case 'create'
                        %error('ERROR: file cannot be created because it already exists');
                    case 'overwrite'
                        if SMASH.FileAccess.SDAfile.isWritable(filename)
                            delete(filename)
                        else
                            error('ERROR: archive is not writable');
                        end
                        if verbose
                            fprintf('Overwriting archive \n');
                        end
                        object=SMASH.FileAccess.SDAfile(filename);                        
                    case 'append'
                        try
                            format=readAttribute(filename,'/','FileFormat');
                            assert(strcmp(format,'SDA'));
                        catch
                            error('ERROR: invalid SDA file');
                        end
                        if verbose
                            fprintf('Appending archive \n');
                        end
                    otherwise
                        error('ERROR: invalid archive argument');
                end
            else
                if verbose
                    fprintf('Creating new archive \n');
                end
                fid=fopen(filename,'w');
                fclose(fid);
                h5writeatt(filename,'/','FileFormat','SDA');
                h5writeatt(filename,'/','FormatVersion','1.1');
                h5writeatt(filename,'/','Created',datestr(now));
                h5writeatt(filename,'/','Updated',datestr(now));
                h5writeatt(filename,'/','Writable','yes');
            end
            % match properties with file
            object.Writable=readAttribute(filename,'/','Writable');            
        end        
    end
    %%
    methods        
        function object=set.Writable(object,value)
            switch value
                case {1,true,'yes','y'}
                    h5writeatt(object.ArchiveFile,'/','Writable','yes'); %#ok<MCSUP>
                    object.Writable='yes';
                case {0,false,'no','n'}
                    h5writeatt(object.ArchiveFile,'/','Writable','no'); %#ok<MCSUP>
                    object.Writable='no';
                otherwise
                    error('ERROR: invalid Writable setting');
            end
        end        
    end
    %%
    methods (Static=true)
        function state=isWritable(filename)
            try
                state=readAttribute(filename,'/','Writable');
            catch                
                state=[];
            end
            if strcmpi(state,'yes')
                state=true;
            else
                state=false;
            end
        end
    end
    
end