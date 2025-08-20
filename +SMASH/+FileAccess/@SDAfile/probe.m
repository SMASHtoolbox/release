
% probe Probe archive file
% 
% This method probes the state and contents of an archive file.  When
% called without outputs:
%   >> probe(archive);
% the function prints the state and contents to the command window.
% Specific values are returned as outputs.
%   >> [label,type,description,status]=probe(object);
%
% The default behavior of this method is to return *all* records contained
% in an archive.  Results can be limited by passing a search text pattern.
%   >> probe(object,pattern);
% 
% See also SDAfile, select
%

%
% created October 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%    -altered method to match revised SDA specification
%
function varargout=probe(object,target)

% handle input
if nargin<2
    target='';
else
    target=regexptranslate('wildcard',target);
end

% extract labels
info=h5info(object.ArchiveFile);
Ngroups=numel(info.Groups);
[label,description,type]=deal(cell(1,Ngroups));
keep=true(1,Ngroups);
for k=1:Ngroups
    temp=info.Groups(k).Name;
    if iscell(temp)
        keyboard
    end
    label{k}=temp(2:end);
    description{k}=readAttribute(object.ArchiveFile,temp,'Description');
    type{k}=readAttribute(object.ArchiveFile,temp,'RecordType');
    % determine if record matches target pattern
    if isempty(target)
        continue
    end
    start=regexp(label{k},target,'once');
    if isempty(start)
        keep(k)=false;
    end
end
label=label(keep);
description=description(keep);
type=type(keep);
Ngroups=numel(label);

% handle output
if nargout==0
    if isempty(label)
        fprintf('No records found\n');
        return
    end
    width(1)=max(cellfun(@numel,label));
    width(1)=max(width(1),numel('Label'));
    width(2)=max(cellfun(@numel,type));
    width(2)=max(width(2),numel('Type'));
    width(3)=max(cellfun(@numel,description));
    width(3)=max(width(3),numel('Description'));
    width=width+2; % a little extra room
    format=[...
        sprintf('%%-%ds',width(1)) ' ' ...
        sprintf('%%-%ds',width(2)) ' ' ...
        sprintf('%%-%ds',width(3)) '\n'];
    fprintf('Archive file status:\n');
    checkStatus(object);    
    fprintf('%s\n',repmat('-',[1 sum(width)+2+3]));
    fprintf(format,'Label','Type','Description');
    fprintf('%s\n',repmat('-',[1 sum(width)+2+3]));
    for k=1:Ngroups
        fprintf(format,label{k},type{k},description{k}); 
    end
    fprintf('%s\n',repmat('-',[1 sum(width)+2+3]));
else
    varargout{1}=label;
    varargout{2}=type;
    varargout{3}=description;
    varargout{4}=checkStatus(object);
end

end