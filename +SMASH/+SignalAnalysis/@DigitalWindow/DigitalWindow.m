% DigitalWindow Digital window class
%
% This class provides digital windows used in signal frequency analysis.
% Normalized variables are used for generality:
%     -Signals are sampled from time -0.5 to +0.5, i.e. time values are
%     shifted by the mean value and divided by the range.
%     -Frequencies run from -0.5 to +0.5, i.e. frequencies are scaled by
%     the sampling rate.
%     
% Objects can be created by name with optional parameters.
%    object=DigitalWindow(name);
%    object=DigitalWindow(name,param);
% The input "name" can be any of the following.
%     -'boxcar', which has no parameters.
%     -'blackman', which has no parameters.
%     -'bspline', which accepts one parameter (3, 4, or 5).  The default
%     value is 3.
%     -'connes', which has no parameters.
%     -'flattop', which accepts one parameter (3 or 5).  The default value
%     is 3.
%     -'hann', which has no parameters.
%     -'kaiser', which takes one parameter >= 1.  The default value is 16.
%     -'pcosine', which takes one parameter >= 1.  The default value is 2.
%     -'psinc', which takes one parameter >= 1.  The default value is 2.
%     -'singla', which takes one parameter (1 or 2).  The default value is
%     1.
%     -'triangle', which takes one parameter >= 1.  The default value is 1.
%     -'tukey', which takes one parameter between 0 and 1.  The default
%     value is 0.5.
%     -'vorbis', which has no parameers
% The default choice is 'hann' when the class is called without input.  
%
% Custom window functions can be specified with a function handle.
%    object=DigitalWindow(@(x) custom(x));
% These functions must accept an input array and return an array of the
% same size.  
%
% References:
% -F. Harris, "On the use of windows for harmonic analysis with the
%     discrete Fourier transform", Proceedings of the IEEE 66, 51 (1978).
% -A. Nuttall, "Some windows with very good sidelobe behavior", IEEE
%  Transactions on Acoustics, Speech, and Signal Processing 29, 84 (1981).
% -A.W. Doerry, "Catalog of Window Taper Functions for Sidelobe Control",
% Sandia National Laboratories SAND2017-4042 (2017).
%
% See also SMASH.SignalAnalysis
%
classdef DigitalWindow
    %% general properties
    properties (SetAccess=protected)
        Name          % Window name
        Function      % Time-domain window function
        Time          % Evaluation time array
        Data          % Evaluation data array         
    end   
    %% point properties
    properties (Dependent=true)
        SamplePoints    % Number of signal points
        TransformPoints % Number of transform points (always base 2)
        PeakPoints      % Minimum points in transform peak

    end
    properties (SetAccess=protected, Hidden=true)
        PrivatePoints = [256 nan 10] % sample transform peak
    end    
    methods
        function value=get.SamplePoints(object)
            value=object.PrivatePoints(1);
        end
        function value=get.TransformPoints(object)
            N=object.PrivatePoints(1);
            L=object.PrivatePoints(3);
            if isfinite(object.PrivatePoints(2))
                value=object.PrivatePoints(2);
            else
                value=ceil(N/(2*object.PeakWidth)*L);               
            end            
            N2=pow2(nextpow2(value));
            value=max(value,N2);
        end
        function value=get.PeakPoints(object)
            N=object.SamplePoints;
            if isfinite(object.PrivatePoints(3))
                value=object.PrivatePoints(3);
            else
                N2=object.PrivatePoints(2);
                value=ceil(2*object.PeakWidth*N2/N);                
            end
        end
        function object=set.SamplePoints(object,value)
            assert(isnumeric(value) && isscalar(value) && (value >= 16),...
                'ERROR: sample points must be >= 16');
            object.PrivatePoints(1)=ceil(value);
            if isfinite(object.PrivatePoints(2)) % enfore consistency
                object.TransformPoints=object.TransformPoints;
            end
            object.Time=linspace(-0.5,+0.5,value);
            object.Time=object.Time(:);
            object.Data=object.Function(object.Time);
        end
        function object=set.TransformPoints(object,value)
            assert(isnumeric(value) && isscalar(value)...
                && (value >= object.SamplePoints),...
                'ERROR: transform points must be >= sample points');
            value=pow2(nextpow2(value));
            object.PrivatePoints(2:3)=[value nan];                        
        end        
        function object=set.PeakPoints(object,value)
            assert(isnumeric(value) && isscalar(value)...
                && (value >= 1),...
                'ERROR: transform points must be >= 2');
            value=ceil(value);
            object.PrivatePoints(2:3)=[nan value];
        end
    end
    %%
    properties (Dependent=true)
    end
    %% spectral full width used in point conversions
    properties (SetAccess=protected, Hidden=true)
        PeakWidth = 1 % Estimated spectral FWHM
    end
    methods (Hidden=true)
        varargout=estimateWidth(varargin)
    end
    %% constructor
    methods (Hidden=true)
        function object=DigitalWindow(name,parameter)
            % manage input
            if nargin < 1
                object=packtools.call('.DigitalWindow','hann');
                return
            end
            if nargin < 2
                parameter=[];
            end            
            % define window function
            if ischar(name)                
                try
                    object=createWindow(object,name,parameter);
                catch ME
                    throwAsCaller(ME);
                end                
            elseif isa(name,'function_handle')
                object.Name='Custom';
                try
                    [~]=name(object.TimeBase);
                catch
                    error('ERROR: invalid window function');
                end
                object.Function=name;                
            else
                error('ERROR: invalid input');
            end
            object.SamplePoints=object.SamplePoints; % engage setter
            % time characterization
            numer=integral(@(t) t.^2.*abs(object.Function(t)),-0.5,+0.5);
            denom=integral(@(t) abs(object.Function(t)),-0.5,+0.5);
            gamma=sqrt(numer/denom);
            %object.RiseTime=2*gamma;
            %object.Duration=sqrt(12)*gamma;
            % frequency characterization
            object.PeakWidth=estimateWidth(object,1024,100);
        end
        varargout=createWindow(varargin)
        varargout=characterizeTime(varargin)
        varargout=characterizeFrequency(varargin)
    end   
end