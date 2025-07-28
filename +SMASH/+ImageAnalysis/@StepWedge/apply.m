% apply Apply step wedge to an image
%
% This method linearizes an image using results from step wedge analysis.
%     >> new=apply(object,target);
% The target is an Image that is linearized to produce a new Image.
% Linearization can only be performed after the StepWedge object is
% analyzed!
%
% See also SMASH.ImageAnalysis.StepWedge, analyze, MASH.ImageAnalysis.Image
%

%
% created August 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function target=apply(object,target)

% handle input
if nargin<2
    error('ERROR: insufficient number of inputs');
end

if ~isa(target,'SMASH.ImageAnalysis.Image')
    error('ERROR: target must be an Image object');
end

% make sure analyze has been performed
assert(object.Analyzed,...
    'ERROR: object must be analyzed before it can be applied');

% prepare table
table=object.Results.ReverseTable;
table=sortrows(table,1);

% identify values outside the transfer table
data=target.Data;
index1=(data<table(1,1));
index2=(data>table(end,1));

% map z coordinate using wedge transfer table
target=map(target,'Data','table',table);

data=target.Data;
data(index1)=table(1,2);
data(index2)=table(end,2);
target=reset(target,[],[],data);
