% object=Space({grid1 grid2 ...},data);
% object=Space({grid1 grid2 ...},{data1 data2})

classdef Space
    %%  
    properties (SetAccess=protected)
        Grid % Grid arrays
        Data % Data array(s)
    end
    properties
        GridLabel % Grid label(s)
        DataLabel  % Data label(s)
        Name = 'Space object' % Object name
        Comments = '' % Extensive comments
        GraphicOptions % Graphic options
    end
    properties (Dependent=true, SetAccess=protected)
        Dimension
    end
    properties (Dependent=true)
        Precision % Numeric precision ('double' or 'single')
    end
    properties (Access=protected, Hidden=true)
        PrivatePrecision = 'double'
    end
    
    %%
    methods (Hidden=true)
        function object=Space(varargin)
            % manage input
            if nargin == 0
                return
            elseif nargin < 2
                error('ERROR: invalid input');
            end
            % set up data
            if isempty(varargin{2})
                error('ERROR: space data cannot be empty');
            elseif isnumeric(varargin{2})
                varargin{2}={varargin{2}};
            end           
            for n=1:numel(varargin{2})
                temp=varargin{2}{n};
                assert(~isempty(temp),'ERROR: space data cannot be empty')
                if n == 1
                    ArraySize=size(temp);
                else
                    assert(all(ArraySize == size(temp)),'ERROR: incompatible space data');
                end
            end
            object.Data=varargin{2};
            % set up grid
            if isempty(varargin{1})
                N=numel(ArraySize);
                varargin{1}=cell(N,1);
                for n=1:N
                    varargin{1}{n}=1:ArraySize(n);
                end
            end
            if isnumeric(varargin{1})               
                varargin{1}{1}=varargin{1};
            end
            for n=1:numel(varargin{1})
                temp=varargin{1}{n};
                assert(isnumeric(temp),'ERROR: grid #%d is not valid',n);
                assert(numel(temp) == ArraySize(n),...
                    'ERROR: grid #%d is not compatible with space data',n);
                change=diff(temp);
                assert(all(change > 0) || all(change < 0),...
                    'ERROR: grid #%d is not monotonic');
                varargin{1}{n}=temp(:);
            end
            object.Grid=varargin{1};
            % finish up
            object.GraphicOptions=packtools.call('-.General.GraphicOptions');
            label=cell(object.Dimension.Grid,1);
            for n=1:numel(label)                
                label{n}=sprintf('Grid %d',n);
            end            
            object.GridLabel=label;
            label=cell(object.Dimension.Data,1);
            for n=1:numel(label)
                label{n}=sprintf('Data %d',n);
            end
            object.DataLabel=label;
        end
    end
    %% getters
    methods
        function value=get.Dimension(object)
            value.Grid=numel(object.Grid);
            value.Data=numel(object.Data);
        end        
        function value=get.Precision(object)
            value=object.PrivatePrecision;
        end
    end
    %% setters
    methods
        function object=set.Precision(object,value)
            assert(ischar(value),'ERROR: invalid precision');
            value=lower(value);
            switch value
                case {'single' 'double'}
                    % valid choice
                otherwise
                    error('ERROR: invalid precision');
            end
            convert=@(x) feval(value,x);
            for n=1:object.Dimension.Grid
                object.Grid{n}=convert(object.Grid{n});
            end
            for n=1:object.Dimension.Data
                object.Data{n}=convert(object.Data{n});
            end            
            object.PrivatePrecision=value;
        end
    end
end