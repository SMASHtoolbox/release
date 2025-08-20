% calculateOffset Calculate offset frequency
%
% This method calculates offset frequency for one or more PDV channels. The
% frequency and time bounds used in the calculation may be explicitly
% specified:
%    object=calculateOffset(object,'Frequency',[f1 f2],'Time',[t1 t2]);
% Omitting one of these bounds causes the entire range to be used.
% Omitting both bounds launches interactive selelction.
%    object=calculateOffset(object); % selection on a new figure 
%    object=calculateOffset(object,'Target,target); % selection on existing target axes
%
% Multi-channel offsets are calculated sequentially by default.  Specific
% channels may be analyzed:
%    object=calculateOffset(object,'Channel,index,...);
% where index is one or more integer values.  A common frequency offset can
% also be generated from analysis of the first channel.
%    object=calculateOffset(object,'Channel,'common',...);
%
% See also PDV, generateSpectrogram, view
%

%
% created February 8, 2018 by Daniel Dolan (Sandia National Laboratories
%
function object=calculateOffset(object,varargin)

% manage input
region=SMASH.ROI.Rectangle('xy');
data=region.Data;
data(3:4)=[0 inf];
region=define(region,data);

channel=1:object.NumberChannels;
GUI=true;
target=[];
viewlim=inf;
ShareOffset=false;

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)  
        case 'time'
            try
                data=region.Data;
                data(1:2)=value;
                region=define(region,data);
            catch ME
                throwAsCaller(ME);
            end
            GUI=false;     
        case 'frequency'
            try
                data=region.Data;
                data(3:4)=value;
                region=define(region,data);
            catch ME
                throwAsCaller(ME);
            end
            GUI=false;           
        case 'channel'
            if strcmpi(value,'all')
                channel=1:object.NumberChannels;
            elseif strcmpi(value,'common')
                channel=1;
                ShareOffset=true;
            elseif isnumeric(value)
                for k=1:numel(value)
                    assert(any(value(k) == channel),...
                        'ERROR: invalid channel number');
                end
                channel=value;
            else
                error('ERROR: invalid channel number');
            end
        case 'target'
            assert(all(ishandle(target)),'ERROR: inavlid target axis');
            target=value;
        case 'maxfrequencyview'
            viewlim=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% calculate offsets
if GUI    
    for k=channel
        temp=object.PrivateSpectrogram{k};
        if ~object.ShowNegativeFrequencies
            temp=crop(temp,[],[0 viewlim]);
        else
            temp=crop(temp,[],[-viewlim viewlim]);
        end
        if isempty(target)
            target=view(temp); % Image.view call
            target=target.axes;
            NewFigure=true;            
        else
            NewFigure=false;
        end
        title('Select offset');
        ylabel('Beat frequency','FontWeight','bold');
        region.Name=sprintf('Channel %d offset region',k);
        if isscalar(target)
            region=select(region,target);
        else
            region=select(region,target(k));
        end
        if NewFigure
            fig=ancestor(target(1),'figure');
            delete(fig);
            target=[];
        end
        findCenter(k);
    end
else
    for k=channel
        findCenter(k);
    end
    
end
    function findCenter(index)
        temp=object.Channel{index}.Measurement;
        temp=crop(temp,region.Data(1:2));
        assert(numel(temp.Data) > 1,...
            'ERROR: no data inside time bounds');
        option=object.FFToptions;
        option.NumberFrequencies=[1000 inf];
        temp=fft(temp,option);
        temp=crop(temp,region.Data(3:4));
        assert(numel(temp.Data) > 1,...
            'ERROR: no data inside frequency bounds');
        report=object.findPeak(temp);
        object.OffsetFrequency(index)=report.Location;
    end

if ShareOffset
   object.OffsetFrequency=repmat(object.OffsetFrequency(1),...
       size(object.Channel)); 
end

object=changeStatus(object,'obsolete','history');

end