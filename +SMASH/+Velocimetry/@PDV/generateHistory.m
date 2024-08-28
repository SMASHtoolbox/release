% generateHistory Generate history data
%
% This method generates history data for the current partition settings.
%    object=generateHistory(object); % default analysis
%    object=generateHistory(object,'Analysis',type); % specified analysis 
% Results are stored in the History property as a cell array of SignalGroup
% objects.  Analysis options may be passed as name/value pairs.
%    object=generateHistory(object,name,value,...);
%
%
% The default analysis type identifies peak locations in the power
% spectrum.  This approach works well for distinct (non-overlapping)
% features.  Analysis options include:
%    -MaxIteration : Maximum number of iterations to locate peak (default is 10).
%    -Tolerance    : Relative frequency convergence tolerance (default is 1e-3).
%    -Scale        : Peak width scale factor (default is 2).
%    -MinWidth     : Minimum frequency width (default is 0).
%
% All analysis, Fourier transform, and partition parameters used in
% history generation are recorded in the HistorySettings property.  Object
% modifications that change any of these settings will make the complete
% history data obsolete.
%
% See also PDV, generateHistory, view
%

%
% created February 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function [object,raw]=generateHistory(object,varargin)

assert(strcmpi(object.Status.Reference,'complete'),...
    'ERROR: cannot perform histories without reference selection');

object.HistorySettings.FFToptions=object.FFToptions;
object.HistorySettings.Partition=object.Partition;

% manage input
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    if strcmpi(name,'Analysis')
        assert(ischar(value),'ERROR: invalid analysis value');
        object.HistorySettings.Analysis=value;
    elseif strcmpi(name,'AnalysisOptions')
        assert(isstruct(value),'ERROR: invalid analysis options value');
        object.HistorySettings.AnalysisOptions=value;
    else
        error('ERROR: invalid history setting');
    end
end

% make sure noise values are available
if ~strcmpi(object.Status.Noise,'complete')
    fprintf('Updating noise spectra...');
    object=calculateNoise(object);
    fprintf('done\n');
end

% make sure at least one region is available
if strcmpi(object.Status.ROI,'complete')
    region=object.ROIselection;
elseif strcmpi(object.Status.ROI,'obsolete')
    error('ERROR: cannot generate history when ROI selection is obsolete');
else    
    message={};
    message{end+1}='History generated from entire time-frequency domain';
    message{end+1}='ROI selection typically yields better results';
    warning('PDV:missingROI','%s\n',message{:});
    region=SMASH.ROI.Curve('x');    
    region.Name='Default ROI';
end

% perform analysis
switch lower(object.HistorySettings.Analysis)
    case 'power'
        [raw,object]=analyzePower(object,region);
    otherwise
        error('ERROR: %s is not a valid analysis mode',...
            object.HistorySettings.AnalysisMode);
end

% post processing
object.History=cell(size(region));
for n=1:numel(region)    
    temp=cell(1,object.NumberChannels);
    for m=1:object.NumberChannels
        temp{m}=raw{m}{n};
    end
    temp=gather(temp{:});
    object.History{n}=evaluate(temp,@WeightedAverage);
    object.History{n}.GridLabel=object.Label.Time;
    object.History{n}.Legend{1}=object.Label.Velocity;
    object.History{n}.Legend{2}=object.Label.Uncertainty;
    object.History{n}.Legend{3}=object.Label.Amplitude;
    object.History{n}.Name=sprintf('Region %d',n);
end

object.Status.History='complete';

end

function output=WeightedAverage(table)

velocity=table(:,1:3:end);
uncertainty=table(:,2:3:end);
amplitude=table(:,3:3:end);

weight=1./uncertainty.^2;
total=sum(weight,2);
uncertainty=1./sqrt(total);

weight=bsxfun(@rdivide,weight,total);
weight(total == 0,:)=1;

velocity=sum(weight.*velocity,2);
amplitude=sum(weight.*amplitude,2);

output=[velocity uncertainty amplitude];

end