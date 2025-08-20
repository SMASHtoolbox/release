function [data,grid1,grid2]=read_plate(name)

[~,~,ext]=fileparts(name);
switch lower(ext)
    case '.img'
        [data,info]=read_fujiIMG(name);
        dx=sscanf(info{4},'%g',1);
        dy=sscanf(info{5},'%g',1);
        grid1=1:size(data,2);
        grid1=(grid1-1)*dx;
        grid2=1:size(data,1);
        grid2=(grid2-1)*dy;
        grid2=grid2(:);
    case '.tif'
        [data,~,grid1,~,grid2] = read_ditabis(name);
end

end