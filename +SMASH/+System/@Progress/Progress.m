%
classdef Progress < handle
    %%
    properties (SetAccess=immutable)
        Iterations % total number of iterations to be performed
    end
    properties
        Title = 'Calculation progress: ' % title printed left of the display
        Threshold = 0.05 % minimum progress needed to update display
    end
    properties (SetAccess=protected)
        Value = 0
    end
    properties (SetAccess=protected,Hidden=true)
        Width
        Trigger
    end
    %%
    methods (Hidden=true)
        function object=Progress(iterations)
            assert(nargin>0,'ERROR: number of iterations must be specified');
            if isnumeric(iterations) && isscalar(iterations) && (iterations>0)
                object.Iterations=iterations;
            else
                error('ERROR: invalid number of iterations');
            end
        end
    end
    %%
    methods
        function start(object)
            fprintf('%s',object.Title);
            object.Width=fprintf(' %.1f%%',0);
            object.Value=0;
            object.Trigger=0:object.Threshold:1;
            object.Trigger=round(object.Trigger*object.Iterations);
            object.Trigger=object.Trigger(2:end);
            commandwindow;
        end
        function increment(object)
            object.Value=object.Value+1;
            if object.Value<object.Trigger(1)
                return
            end
            back=repmat('\b',[1 object.Width]);
            fprintf(back);
            if object.Value<object.Iterations
                object.Width=fprintf(' %.1f%%',object.Value/object.Iterations*100);
                object.Trigger=object.Trigger(2:end);
            else
                fprintf(' complete\n');
            end
        end
        
    end
    %%
    
end