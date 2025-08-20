function showDocumentation(MainFile)

if (nargin < 1)
    MainFile='UsingSIRHEN';
end

source=fileparts(fileparts(mfilename('fullpath')));
source=fullfile(source,'doc');
list=dir(fullfile(source,'*.m'));

target=fullfile(tempdir,'SIRHEN','doc');
if ~exist(target,'dir')
    mkdir(target)
end
copyfile(source,target,'f');
for n=1:numel(list)    
    temp=fullfile(target,list(n).name);
    publish(temp,'format','html','evalCode',false);
end

web(fullfile(target,'html',[MainFile '.html']));


end