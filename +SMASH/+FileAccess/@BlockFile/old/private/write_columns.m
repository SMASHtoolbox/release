function success=write_columns(filename,data,varargin)

% handle input
numcol=size(data,2);
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value input');
options=struct();
format=repmat('%+#g ',[1 numcol]);
options.Format=[strtrim(format) '\n'];
options.Header={};
for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};    
    options.(name)=value;   
end

% write the file
fid=fopen(filename,'w');
try
    fprintf(fid,'%s\n',options.Header{:});
    fprintf(fid,options.Format,transpose(data));
    success=true;
catch
    fprintf('There was a problem...');
    success=false;
end
fclose(fid);