function set_colormap(haxes,map,invertmap)

N=256;
try 
    map=feval(map,N);    
catch
    map=colormap('default');
end
if strcmp(invertmap,'yes')
    map=map(end:-1:1,:);
end

colormap(haxes,map)

end

% red color map (inspired by IDL)
function map=red(numcolors)

N=linspace(1,numcolors,3);
N=round(diff(N));
red=[linspace(0,1,N(1)) linspace(1,1,N(2))];
green=[linspace(0,0,N(1)) linspace(0,1,N(2))];
blue=[linspace(0,0,N(1)) linspace(0,1,N(2))];

map=[red(:) green(:) blue(:)];
 
end

% green color map (inspired by IDL)
function map=green(numcolors)

N=linspace(1,numcolors,3);
N=round(diff(N));
red=[linspace(0,0,N(1)) linspace(0,1,N(2))];
green=[linspace(0,0.5,N(1)) linspace(0.5,1,N(2))];
blue=[linspace(0,0,N(1)) linspace(0,1,N(2))];

map=[red(:) green(:) blue(:)];
 
end

% blue color map (inspired by IDL)
function map=blue(numcolors)

N=linspace(1,numcolors,3);
N=round(diff(N));
red=[linspace(0,0,N(1)) linspace(0,1,N(2))];
green=[linspace(0,0,N(1)) linspace(0,1,N(2))];
blue=[linspace(0,1,N(1)) linspace(1,1,N(2))];

map=[red(:) green(:) blue(:)];
 
end

function map=rainbow(numcolors,gamma)

if (nargin<2) || isempty(gamma)
    gamma=0.80;
end

%wavelength=linspace(400,700,numcolors);
wavelength=linspace(700,400,numcolors);
[red,green,blue]=deal(zeros(size(wavelength)));

index=(wavelength>=380) & (wavelength<=440);
red(index)=-1*(wavelength(index)-440)/(440-380);
green(index)=0;
blue(index)=1;

index=(wavelength>=440) & (wavelength<=490);
red(index)=0;
green(index)=(wavelength(index)-440)/(490-440);
blue(index)=1;

index=(wavelength>=490) & (wavelength<=510);
red(index)=0;
green(index)=1;
blue(index)=-1*(wavelength(index)-510)/(510-490);

index=(wavelength>=510) & (wavelength<=580);
red(index)=(wavelength(index)-510)/(580-510);
green(index)=1;
blue(index)=0;

index=(wavelength>=580) & (wavelength<=645);
red(index)=1;
green(index)=-1*(wavelength(index)-645)/(645-580);
blue(index)=0;

index=(wavelength>=645) & (wavelength<=780);
red(index)=1;
green(index)=0;
blue(index)=0;

map=[red(:) green(:) blue(:)];
map=map.^gamma;
end