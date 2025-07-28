% UNDER CONSTRUCTION
%
%    data=read(object); % return two-column array
%
%    read(object); % plot spectrum in a new figure
% 
% See also GalacticSPC
function varargout=read(object)

fid=fopen(object.File,'r');
CU=onCleanup(@() fclose(fid));
fseek(fid,object.StartByte,'bof');

info=object.Information;
N=info.NumPoints;
data=nan(N,2);
data(:,1)=linspace(info.FirstPoint,info.LastPoint,N);

switch object.Format
    case '4D'
        y=fread(fid,2*N,'*int16');
        y=reshape(y,[2 N]);
        y=y([2 1],:);
        y=typecast(y(:),'int32');
    otherwise
end
y=double(y);

data(:,2)=pow2(object.Information.Exponent)*y/pow2(32);

if nargout == 0
    figure();
    plot(data(:,1),data(:,2));
    xlabel(object.Information.XUnit);
    ylabel(object.Information.YUnit);
else
    varargout{1}=data;
end

end