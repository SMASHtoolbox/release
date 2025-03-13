% register Register target Image(s) to a master Image
%
% This method registers a target Image to a master Image using common
% points in each object.  Three or more (x,y) locations must be identified
% to transform the target Image to the same coordinates as the master
% Image.  These locations are passed to the calculation as two-column
% arrays as shown below.
%     >> result=register(master,target,mtable,ttable);
% The third and fourth inputs are registration points arrays for the master
% and target objects, respectively.  Point order must be consistent: each
% row of mtable and ttable should correspond to the same physical point.
%
% Passing target Images:
%    >> [A,B]=register(master,{A B},mtable,{ttableA ttableB});
% allows several objects to be simultaneously registered to the same master
% Image.  Multiple objects must be passed as a cell array, and the
% corresponding registration tables must be passed as a cell array of the
% same size.
% 
% Passing an ImageGroup as a target will apply the register to all the
% Images within that group. Only one target table needs to be submitted,
% the same one will be used on all the Images.
% 
% By default, this method uses translation, shifting, and rotation for
% image registration.  Shear can be added with final input arguement.
%     >> [...]=register(...,'shear'); % default is 'noshear'
% Shear requires at least four registration points and is not recommended
% for less than five registration points.
% 
% See also Image, rotate, center
%

%
% Interative point selection under construction
%    >> [objectA,objectB,...]=register(master,target); % not supported yet!
%    

%
% created November 5, 2014 by Daniel Dolan (Sandia National Laboratories)
% modified February 19, 2016 by Sean Grant (Sandia National Laboratories)
%   -Included ImageGroup functionality.
%
function varargout=register(varargin)

% handle input
if (nargin==2) || (nargin==3)
    error('ERROR: interactive mode not supported yet');    
elseif nargin>=4
    MasterTable=varargin{3};
    TargetTable=varargin{4};
else
    error('ERROR: invalid number of inputs');
end
Master=varargin{1};
Target=varargin{2};

if nargin<5
    mode='noshear';
else
    mode=varargin{5};
end
assert(strcmpi(mode,'shear') | strcmpi(mode,'noshear'),...
    'ERROR: invalid mode');

% Handle ImageGroup target input
if isa(Target,'SMASH.ImageAnalysis.ImageGroup')
    temp=cell(object.NumberImages,1);
    [temp{:}]=split(Target);
    Target=temp;
    
    % Handle TargetTable
    TargetTable=repmat({TargetTable},object.NumberImages,1);
end

if ~iscell(Target)
    Target={Target};
end

if ~iscell(TargetTable)
    TargetTable={TargetTable};
end

% error checking
NTarget=numel(Target);
for k=1:NTarget
    assert(isa(Target{k},'SMASH.ImageAnalysis.Image'),...
        'ERROR: invalid Target object(s)');
end

assert(isnumeric(MasterTable) & ismatrix(MasterTable),...
    'ERROR: invalid Master table');
[Npoints,Ncolumns]=size(MasterTable);
assert(Npoints>=3,'ERROR: MasterTable must have at least three rows');
assert(Ncolumns==2,'ERROR: MasterTable must have two columns');

assert(numel(TargetTable)==NTarget,...
    'ERROR: TargetTable size does not match Target size');
for k=1:NTarget
    table=TargetTable{k};
    assert(isnumeric(table) & ismatrix(table),...
        'ERROR: invalid reference array');
    assert(size(table,1)==Npoints,...
        'ERROR: TargetTable entry size does not match MasterTable size');
    assert(size(table,2)==2,'ERROR: invalid TargetTable entry');
end

% create master grids
x=Master.Grid1;
y=Master.Grid2;
[X,Y]=meshgrid(x,y);

% apply registration
varargout=cell(size(Target));
for k=1:NTarget
    [a,b]=transferParameters(MasterTable,TargetTable{k},mode);
    P=a(1)+a(2)*X+a(3)*Y+a(4)*X.*Y;
    Q=b(1)+b(2)*X+b(3)*Y+b(4)*X.*Y;
    varargout{k}=Target{k};
    varargout{k}.Data=interp2(...
        Target{k}.Grid1,Target{k}.Grid2,Target{k}.Data,P,Q);
    jacobian=...
        (a(2)+a(4)*Q).*(b(3)+b(4)*P)-(b(2)+b(4)*Q).*(a(3)+a(4)*P);
    varargout{k}=varargout{k}./jacobian;
    varargout{k}.Grid1=Master.Grid1;
    varargout{k}.Grid1Label=Master.Grid1Label;
    varargout{k}.Grid2=Master.Grid2;
    varargout{k}.Grid2Label=Master.Grid2Label;
    varargout{k}.Source='register';
end

end

function [a,b]=transferParameters(master,target,mode)

x=master(:,1);
y=master(:,2);
p=target(:,1);
q=target(:,2);

N=numel(x);
matrix=ones(N,3);
matrix(:,2)=x;
matrix(:,3)=y;
if (N>=4) && strcmp(mode,'shear')
    matrix(:,4)=x.*y;
end

a=matrix\p;
b=matrix\q;

if (N==3) || strcmp(mode,'noshear')
    a(4)=0;
    b(4)=0;
end

end