% This class manages independent bounds for a parameter array. The number
% of parameters is arbitrary but fixed at object creation.
%    object=BoundParameter(param);
% Each parameter is associated with a unbounded slack variable and a
% finite, semi-infinite, or infinite (default) range of allowed values.
% The "bound" method allows minimum/maximum values to be associated with
% each parameter.
%
% Current parameter and slack variable values are stored as object
% propertes.
%    param=object.Parameter;
%    slack=object.Slack;
% Changing either of these properties automatically updates the other using
% the defined parameter bounds.
%    object.Parameter=param; % updates Slack property
%    object.Slack=slack; % updates Parameter property
%
% BoundParameter objects provide a convenient interface between model
% functions (which use parameters) and optimization (which uses the slack
% variables).
%
% See also CurveFit
%

%
% created September 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
classdef BoundParameter
    %%    
    properties
        ParameterName % Parameter names (cell array)
    end
    properties (Dependent=true)
        Slack % slack parameter values (numeric array)
        Parameter % parameter values (numeric array)
    end
    properties (SetAccess=protected)
        Bound % min/max parameter values (two-column array)
    end
    properties                                
        VerifyInput = true % Perform input checks (logical value)
    end
    properties (Access=protected, Hidden=true)
        NumberParameters %
        SlackValue % 
    end
    %%
    methods (Hidden=true)
        function object=BoundParameter(arg)
            assert((nargin==1) && isnumeric(arg),...
                'ERROR: invalid input');
            N=numel(arg);
            name=cell(N,1);
            for n=1:N
                name{n}=sprintf('Parameter %d',n);
            end        
            object.ParameterName=name;
            object.NumberParameters=N;
            object.SlackValue=arg(:);            
            object.Bound=repmat([-inf +inf],[N 1]);
        end        
    end
    methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.CurveFit.BoundParameter(data.Parameter);
            object=bound(object,data.Bound);
            object.VerifyInput=data.VerifyInput;
        end
    end
    %% setters
    methods
        function object=set.ParameterName(object,value)
            if isempty(object.ParameterName)
                object.ParameterName=value;
                return;
            end
            assert(iscell(value) && numel(value) == numel(object.ParameterName),...
                'ERROR: invalud parameter name input');
            object.ParameterName=value;
        end
        function object=set.Slack(object,value)
            if object.VerifyInput
                assert(numel(value)==numel(object.SlackValue),...
                    'ERROR: invalid number of slack parameters');
                assert(isnumeric(value),...
                    'ERROR: slack parameters must be numeric');
            end
            object.SlackValue=value;
        end
        function object=set.Parameter(object,value)
            if object.VerifyInput                
                assert(numel(value)==numel(object.SlackValue),...
                    'ERROR: invalid number of parameters');
                assert(isnumeric(value),...
                    'ERROR: parameters must be numeric');
                for n=1:object.NumberParameters
                    if isnan(value(n))
                        continue
                    end
                    bnd=object.Bound(n,:);
                    assert((value(n) >= bnd(1)) && value(n) <= bnd(2),...
                        'ERROR: requested parameter value(s) fall outside specified bounds');
                end
            end
            for n=1:object.NumberParameters
               bnd=object.Bound(n,:);
               flag=isinf(bnd);
               if all(flag)
                   object.SlackValue(n)=value(n);
               elseif flag(1)
                   object.SlackValue(n)=sqrt(bnd(2)-value(n));                   
               elseif flag(2)
                   object.SlackValue(n)=sqrt(value(n)-bnd(1));
               else
                   baseline=(bnd(1)+bnd(2))/2;
                   amplitude=(bnd(2)-bnd(1))/2;
                   object.SlackValue(n)=asin((value(n)-baseline)/amplitude);
               end
           end
        end
        function object=set.VerifyInput(object,value)
            assert(isscalar(value) && islogical(value),...
                'ERROR: VerifyInput value must be logical');
            object.VerifyInput=value;
        end
    end
    %% getters
    methods
        function value=get.Slack(object)
            value=object.SlackValue;
        end
        function value=get.Parameter(object)
           value=nan(object.NumberParameters,1);
           for n=1:object.NumberParameters
               bnd=object.Bound(n,:);
               flag=isinf(bnd);
               if all(flag)
                   value(n)=object.SlackValue(n);
               elseif flag(1)
                   value(n)=bnd(2)-object.SlackValue(n)^2;
               elseif flag(2)
                   value(n)=bnd(1)+object.SlackValue(n)^2;
               else
                   baseline=(bnd(1)+bnd(2))/2;
                   amplitude=(bnd(2)-bnd(1))/2;
                   value(n)=baseline+amplitude*sin(object.SlackValue(n));
               end
           end
        end       
    end
end