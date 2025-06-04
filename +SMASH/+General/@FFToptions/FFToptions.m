% This class manages FFT options in various parts of the SMASH package
%
% See also SMASH.General
% 

%
% created December 12, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef FFToptions
    %%
    properties
        Window = 'hann' % Digital window function (name, name/parameter, or array)
        NumberFrequencies = 1000 % Mininum number of frequency values (integer)
        RemoveDC = true; % Remove DC component (true or false)        
        FrequencyDomain = 'positive' % Frequency domain ('positive', 'negative', 'all'?)
        SpectrumType = 'power' % Spectrum type ('power', 'complex')
    end
    properties (Hidden=true)
        Normalization = 'parseval' % Spectal normalization ('parseval','none');
    end
    %% hidden methods
    methods (Hidden=true)
        function object=FFToptions(varargin)            
            % handle input
            assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');
            for n=1:2:nargin
                name=varargin{n};
                assert(isprop(object,name),'ERROR: invalid name');
                object.(name)=varargin{n+1};
            end
        end
    end
%% static methods
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=SMASH.General.FFToptions();
            name=fieldnames(data);
            for k=1:numel(name)
                if isprop(object,name{k})
                    object.(name{k})=data.(name{k});
                end
            end
        end
    end
    %% property setters
    methods
        function object=set.Window(object,value)
            if isempty(value)
                value='gaussian';
            end
            if ischar(value)
                switch lower(value)
                    case {'boxcar','hann','hamming','gaussian'}
                        object.Window=value;
                    otherwise
                        error('ERROR: invalid Window name');
                end
            elseif iscell(value)
                if strcmpi(value{1},'gaussian') && isnumeric(value{2})
                    object.Window=value;
                else
                    error('ERROR: invalid Window name/parameter(s)');
                end
            elseif isnumeric(value)
                object.Window=value;
            else
                error('ERROR: invalid Window setting');
            end
        end
        function object=set.NumberFrequencies(object,value)
            if isempty(value)
                value=1000;
            end
            assert(isnumeric(value),...
                'ERROR: invalid NumberFrequencies value');            
            if numel(value)==1
                value(2)=inf;
            end    
            assert(numel(value)==2,...
                'ERROR: invalid NumberFrequencies value');
            test(1)=SMASH.General.testNumber(value(1),'integer');
            test(2)=SMASH.General.testNumber(value(2),'integer') | isinf(value(2));
            test(3)=all(value>0);
            test(4)=value(2)>value(1);
            assert(all(test),'ERROR: invalid NumberFrequencies value');
            object.NumberFrequencies=value;
        end
        function object=set.RemoveDC(object,value)
            if isempty(value)
                value=true;
            end
            assert(islogical(value),'ERROR: invalid RemoveDC value');
            object.RemoveDC=value;
        end        
        function object=set.FrequencyDomain(object,value)
            assert(ischar(value),'ERROR: invalid FrequencyDomain value');
            value=lower(value);
            switch value
                case {'positive','negative','all','full'}
                    object.FrequencyDomain=value;
                otherwise
                    error('ERROR: invalid FrequencyDomain value');
            end
        end
        function object=set.SpectrumType(object,value)
            assert(ischar(value),'ERROR: invalid SpectrumType value');
            value=lower(value);
            switch value
                case {'power','complex'}
                    object.SpectrumType=value;
                otherwise
                    error('ERROR: invalid SpectrumType value');
            end
        end
        function object=set.Normalization(object,value)
            assert(ischar(value),'ERROR: invalid Normalization value');
            value=lower(value);
            switch value
                case {'parseval' 'none'}
                    object.Normalization=value;
                otherwise
                    error('ERROR: invalid Normalization value');
            end
        end
    end
end