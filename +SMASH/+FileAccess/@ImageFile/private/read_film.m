
function [data,grid1,grid2,record,info]=read_film(name,record)

if nargin<2
    record=[];
end

[pathname,filename,ext]=fileparts(name);
switch lower(ext)
    case '.img'
        if strcmp(ext,'.img')
            headerfile=fullfile(pathname,[filename '.hdr']);
        else
            headerfile=fullfile(pathname,[filename '.HDR']);
        end
        if ~exist(headerfile,'file')
            error('ERROR: header file \n\t%s\ndoes not exist!',headerfile);
        end
        header=textread(headerfile, '%s', 'delimiter', ' ');
        %header=textscan(headerfile, '%s', 'delimiter', ' ');
        info=header;
        nx=str2double(header{6}); % nx = Number of X Points 
        ny=str2double(header{14}); % ny = Number of Y Points
        data=multibandread(name,[ny,nx,1],'int16',0,'bsq','native'); % Read 16 bit [nx ny] matrix
        data=double(data)/800; % divide signal by 800 to match the expected exposure values of 0 - 5.
        x0=0; y0=0;
        dx=1; dy=1;
        for n=1:numel(header)
            switch lower(header{n})
                case 'xpos'
                    x0=sscanf(header{n+2},'%g',1);
                case 'deltax='
                    dx=sscanf(header{n+1},'%g',1);
                case 'ypos'
                    y0=sscanf(header{n+2},'%g',1);
                case 'deltay='
                    dy=sscanf(header{n+1},'%g',1);
            end
        end
        grid1=1:size(data,2);
        grid1=x0+(grid1-1)*dx;
        grid1=grid1/1000; % convert um to mm
        grid2=1:size(data,1);
        grid2=transpose(y0+(grid2-1)*dy);
        grid2=grid2/1000; % convert um to mm
    case '.h5' % Added by J.R. Fein, 04/27/2020
        info=h5info(name);
        info = info.Groups;
        
        data=double(h5read(name,[info.Name '/' info.Datasets(end).Name]));
        info=info.Datasets(end);
        
        % Flip
        for n=1:numel(info.Attributes)
            if strcmpi(info.Attributes(n).Name,'scan_type')
                value=info.Attributes(n).Value;
                if iscell(value)
                    value = value{1};
                end
                if strcmpi(value,'flip')
                    data = flipud(data);
                end
                break
            end
        end
        
        % Offset and scale
        offset=0;
        scale=1;
        for n=1:numel(info.Attributes)
            name=info.Attributes(n).Name;
            value=info.Attributes(n).Value;
            if iscell(value)
                value = value{1};
            end
            if ischar(value)
                value = str2double(value);
            end
            switch name
                case 'scale_factor'
                    scale=value;
                case 'add_offset'
                    offset=value;
            end
        end
        data=scale*data+offset;
        %output.Information=info.Attributes;
        
        % Grid spacing
        value=[1 1];
        for n=1:numel(info.Attributes)
            if strcmpi(info.Attributes(n).Name,'pds_spacing')
                value=info.Attributes(n).Value;
                if iscell(value)
                    value = value{1};
                end
                value=sscanf(value,'%g');
                value=abs(value);
                break
            end
        end
        grid1=1:size(data,2);
        grid1=(grid1-1)*value(1);
        grid1=grid1/1000; % convert um to mm
        grid2=1:size(data,1);
        grid2=transpose((grid2-1)*value(2));
        grid2=grid2/1000; % convert um to mm
%         info=h5info(name);
%         grid1=double(h5read(name,'/HDF4_DIMGROUP/fakeDim1')); % Grid1 and Grid2 flipped, J.R. Fein, 04/27/2020
%         grid1=grid1/1000; % convert um to mm
%         grid2=double(h5read(name,'/HDF4_DIMGROUP/fakeDim0'));
%         grid2=grid2/1000; % convert um to mm        
%         data=double(h5read(name,'/HDF4_DIMGROUP/pds_image'));
%         scale=h5readatt(name,'/HDF4_DIMGROUP/pds_image','scale_factor');
%         scale=sscanf(scale{1},'%g',1);
%         data=data*scale;
    case '.hdf'
        info=hdfinfo(name);
        info=info.SDS;
        data=double(hdfread(name,info.Name));
        offset=0;
        scale=1;
        for n=1:numel(info.Attributes)
            name=info.Attributes(n).Name;
            value=info.Attributes(n).Value;
            switch name
                case 'scale_factor'
                    scale=value;
                case 'add_offset'
                    offset=value;
            end
        end
        data=scale*data+offset;
        %output.Information=info.Attributes;
        value=[1 1];
        for n=1:numel(info.Attributes)
            if strcmpi(info.Attributes(n).Name,'pds_spacing')
                value=info.Attributes(n).Value;
                value=sscanf(value,'%g');
                value=abs(value);
                break
            end
        end
        grid1=1:size(data,2);
        grid1=(grid1-1)*value(1);
        grid1=grid1/1000; % convert um to mm
        grid2=1:size(data,1);
        grid2=transpose((grid2-1)*value(2));
        grid2=grid2/1000; % convert um to mm
    case '.pff'
        PFF=SMASH.FileAccess.PFFfile(name);
        info=probe(PFF);
        if (isempty(record)) && numel(info)==1
            record=1;
        elseif isempty(record)
            fig=probe(PFF,'gui');
            fig.Hidden=true;
            h=addblock(fig,'Buttons','Done');
            set(h(end),'Callback','delete(gcbo)');
            fig.Hidden=false;
            waitfor(h(end));
            if ishandle(fig.Handle)
                record=probe(fig);
                record=sscanf(record{1},'%g',1);
                delete(fig);
            else
                error('ERROR: no dataset selected');
            end
        end
        if ~any(record==(1:numel(info)))
            error('ERROR: invalid dataset request');
        end
        info=info(record);                
        temp=read(PFF,record);
        switch info.Type
            case 'PFTUF3'
                grid1=temp.X;
                grid2=temp.Y;
                data=temp.Data;
            case 'PFTNGD'
                grid1=temp.X{1};
                grid2=temp.X{2};
                data=temp.Data{1};
            otherwise
                error('ERROR: requested dataset is not a ''film'' image');
        end                              
    otherwise
        error('ERROR: invalid film scan format');
end


end