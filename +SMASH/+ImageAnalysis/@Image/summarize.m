% SUMMARIZE Summarize Image data
% 
% This method provides a statistical summary of the data stored in an Image
% object.
%    >> result=summary(object); 
% The output "result" is a structure containing the mean, standard
% deviation, and other characterizations of the object's Data property over
% its limited region.
%
% See also Signal, limit
%

%
% created May 1, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function result=summarize(object)

% extract data from limited region
[~,~,data]=limit(object);
data=data(:);

% summarize the Data property
result=struct();
result.Mean=mean(data);
result.Std=std(data);
result.Min=min(data);
result.Max=max(data);
result.Median=median(data);

end