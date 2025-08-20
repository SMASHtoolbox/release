% faker : sythesize a three-phase measurement from two-phase data

function faker(infile,outfile)

% handle input
if (nargin<1) || isempty(infile)
    [filename,pathname]=uigetfile('*.*','Select two-phase input file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    infile=fullfile(pathname,filename);
end

if (nargin<2) || isempty(outfile)
    [filename,pathname]=uiputfile('*.*','Select three-phase output file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    outfile=fullfile(pathname,filename);
end

% read input file
data=ColumnReader(infile);
time=data(:,1);
D1=data(:,2);
D2=data(:,3);

% perfom ellipse fit
params=DirectEllipseFit(D1,D2);
baseline=params(1:2);
amplitude=params(3:4);
beta=params(5)+pi/2;

% calculate normalized and quadrature signals
D1n=(D1-baseline(1))/amplitude(1);
D2n=(D2-baseline(2))/amplitude(2);
Dy=cos(beta)*D1n-D2n;
Dx=sin(beta)*D1n;

% determine phase difference
phi=unwrap(atan2(Dy,Dx));

% generate third signal
baseline=mean(baseline);
amplitude=mean(amplitude);
beta=pi-beta/2;
D3=baseline+amplitude*cos(phi-beta);

% write results to a file
data=transpose([time(:) D1(:) D2(:) D3(:)]);
format='%+.6e %+.5f %+.5f %+.5f\n';
fid=fopen(outfile,'wt');
fprintf(fid,format,data);
fclose(fid);
