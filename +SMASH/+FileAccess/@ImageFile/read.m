% READ Read file associated with a ImageFile object
%
% Syntax:
%    >> output=read(object,[option]);
% The option input is used for formats files containing more than one
% image.  The output is a structure with the following fields.
%    -FileName
%    -FileType
%    -FileOption
%    -Grid1
%    -Grid2
%    -Data
%
% Extra information about file is returned as a second output.
%     >> [output,extra]=read(...);
%
%
% See also ImageFile, probe, select
%

function [output,extra]=read(object,~)

% handle input
%if nargin<2
%    record=[];
%end

% error checking
assert(exist(object.FullName,'file')==2,...
    'ERROR: cannot read file because it does not exist');

% call the appropriate reader
output.FileName=object.FullName;
output.Format=object.Format;
map=jet(64);
extra=struct();
switch object.Format 
    case 'graphics'
        [data,map]=imread(object.FullName);
        if isempty(map)
            map=gray(64);
        end
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    case 'hamamatsu'
        [data,header]=read_hamamatsu(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
        extra.Header=header;
    case 'kentech'
        [output,extra]=read_kentech(object.FullName);        
        for n=1:numel(output)
            output(n).FileName=object.FullName;
            output(n).Format=object.Format;
            output(n).ColorMap=map;
        end
        return
    case 'optronis'
        [data,config,header]=read_optronis(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
        extra.Config=config;
        extra.Header=header;
    case 'film'
        [data,grid1,grid2]=read_film(object.FullName);
    case 'plate'
        [data,grid1,grid2]=read_plate(object.FullName);
    case 'sbfp'
        data=read_sbfp(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    case 'sydor'
        [data,info,back]=read_sydor(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
        extra=info;
        extra.Background=back;
    case 'winspec'
        data=read_winspec(object.FullName);
        grid1=1:size(data,2);
        grid2=transpose(1:size(data,1));
    otherwise
        error('ERROR: invalid format');
end

output.Data=data;
output.Grid1=grid1;
output.Grid2=grid2;
output.ColorMap=map;

end

