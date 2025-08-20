% This class provides various window functions used in signal
% analysis.  Individuals windows are provided by static methods, such as:
%    y=WindowFunction.hann(numpoints);
% All window functions accept the number of gridpoints as the first input
% argument.  Some window functions accept additional inputs for shape
% adjustment. 
% 
% Object creation, which is entirely optional, plots an example of each
% window in a new figure.  
%    object=WindowFunction(numpoints);
% Grid and data points for that plot are stored as object properties.
%
% Most functions used here were obtained from:
%    - A. Doerry, "Catalog of window taper functions for sidelobe control",
%    Technical Report SAND2017-4042, Sandia National Laboratories, 2017.
% Additional reference include:
%    - P. Singla and T. Singh, "Desired order continuous polynomial time
%    window functions for harmonic analysis", IEEE Transactions on
%    Instrumentation and Measurement 59, 2475 (2010). 
%
% See also SMASH.SignalAnalysis
%

%
% created June 3, 2020 by Daniel Dolan (Sandia National Laboratories)
%
classdef WindowFunction     
    %%
    properties (SetAccess=protected)
        Grid
        Data
        Label
    end
    %%
    methods (Hidden=true)
        function object=WindowFunction(numpoints)
            % manage input
            if nargin == 0
                numpoints=1000;
            end
            %
            Q=methods(object);
            N=numel(Q);
            object.Label=cell(1,N);
            for k=1:N
                [y,x]=object.(Q{k})(numpoints);
                if k == 1
                    object.Grid=x(:);
                    object.Data=repmat(y(:),[1 N]);
                else
                    object.Data(:,k)=y(:);
                end
                object.Label{k}=Q{k};
            end
            figure();
            h=plot(object.Grid,object.Data);
            for k=1:N
                set(h(k),'Tag',Q{k});
            end
            ylim([-0.2 1.1]);
            legend(object.Label,'Location','south');
            title('Digital window functions');
        end
    end
    %%
    methods (Static=true)
        varargout=blackman(varargin)
        varargout=bspline(varargin)
        varargout=connes(varargin)
        varargout=flattop(varargin)
        varargout=hann(varargin)
        varargout=pcosine(varargin)
        varargout=psinc(varargin)
        varargout=singla(varargin)
        varargout=tukey(varargin)
        varargout=vorbis(varargin)
    end
    
end