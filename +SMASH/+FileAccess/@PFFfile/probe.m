% probe Reveal PFF datasets 
%
% This method determines the datasets inside a PFF file.  The results can
% be returned at the command line:
%    >> probe(object)
% or in a graphical window.
%    >> probe(object,'gui');
% Calling the function with an output returns the contents as a structure.
%    >> dataset=probe(object); % structure array of file contents
%    >> dlg=probe(object,'gui'); % Dialog box handle
%
% See also PFFfile, read, select, write
%

% created October 17, 2013 by Daniel Dolan (Sandia National Laboratories)
function varargout=probe(object,choice)

% handle input
if (nargin<2) || isempty(choice)
    choice='console';
end

% open and verify file
fid=fopen(object.FullName,'r','ieee-be');
CleanObject=onCleanup(@() fclose(fid)); % automatically close file on function exit

FFRAME=ReadWord(fid);
assert(FFRAME==-4,'ERROR: non-PFF file detected');
ldptr=ReadLong(fid); %#ok<NASGU> % beginning of directory datasets
frewind(fid);
header=ReadWord(fid,16);  %#ok<NASGU>

% scan through data sets
dataset=[];
while ~feof(fid)
    % read current header
    start=ftell(fid);
    DFRAME=ReadWord(fid);
    if DFRAME == -1
        % start word
    elseif isempty(DFRAME) || (DFRAME == -2)
        %continue
        break; % stop word
    else
        error('ERROR: start byte not found');
    end
    LDS=ReadLong(fid);
    TRAW=ReadWord(fid);
    VDS=ReadWord(fid);
    ReadWord(fid); % TAPP
    ReadWord(fid,10); % RFU
    TYPE=ReadString(fid);
    TITLE=ReadString(fid);
    % store header
    if isempty(dataset)
        dataset=struct('Type','','TypeVersion',[],'TypeLabel','','Title','');
    else
        dataset(end+1)=dataset(end); %#ok<AGROW>
    end;
    switch TRAW
        case 0
            dataset(end).Type='PFTDIR';
        case 1
            dataset(end).Type='PFTUF3';
        case 2
            dataset(end).Type='PFTUF1';
        case 3
            dataset(end).Type='PFTNF3';
        case 4
            dataset(end).Type='PFTNV3';
        case 5
            dataset(end).Type='PFTVTX';
        case 6
            dataset(end).Type='PFTIFL';
        case 7
            dataset(end).Type='PFTNGD';
        case 8
            dataset(end).Type='PFTNG3';
        case 9
            dataset(end).Type='PFTNI3';
        otherwise
            error('ERROR: unrecognized dataset type');
    end
    dataset(end).TypeVersion=VDS;
    dataset(end).TypeLabel=TYPE;
    dataset(end).Title=TITLE;
    % move to next header
    fseek(fid,start+2*LDS,'bof');
end

% handle output
[~,name,ext]=fileparts(object.FullName);
name=[name ext];
report=PFFreport(dataset,choice);
if (nargout==0) && strcmp(choice,'console')
    fprintf('PFF contents:\n');
    fprintf('   %s\n',report{:});
    fprintf('\n');
elseif strcmpi(choice,'gui')
    fig=SMASH.MUI.Dialog;
    fig.Hidden=true;
    fig.Name='PFF datsets';
    label=sprintf('Datasets in %s',name);
    h=addblock(fig,'listbox',label,report,[],20);
    set(h(end),'FontName',...
        get(0,'FixedWidthFontName'));
    locate(fig,'center');
    set(fig.Handle,'HandleVisibility','off');
    fig.Hidden=false;
    if nargout>=1
        varargout{1}=fig;
    end
else
    varargout{1}=dataset;
end

end