classdef ScatterPatch < SMASH.Developer.SimpleHandle
    %%
    properties (SetAccess=protected)
        RawData    % Raw data array [x y dx dy group enabled]
        GroupList % List of valid group indices        
    end
    %% labeling
    properties
        HorizontalLabel = 'Grid' % Horizontal label for plot method
        VerticalLabel = 'Data'   % Vertical label for plot method
    end
    methods
        function set.HorizontalLabel(object,value)            
            assert(SMASH.General.testLabel(value),...
                'ERROR: invalid horizontal label');
            object.HorizontalLabel=value;
        end
        function set.VerticalLabel(object,value)
            assert(SMASH.General.testLabel(value),...
                'ERROR: invalid vertical label');
            object.VerticalLabel=value;
        end
    end
    %%
    properties
        HorizontalShift
        HorizontalScale
        VerticalShift
        VerticalScale
    end
    methods
        function set.HorizontalShift(object,value)
            if isempty(object.HorizontalShift)
                object.HorizontalShift=value;
                return
            end
            assert(isnumeric(value) && all(isfinite(value)),...
                'ERROR: invalid horizontal shift(s)');
            if isscalar(value)
                value=repmat(value,size(object.HorizontalShift));
            else
                assert(numel(value) == numel(object.HorizontalShift),...
                    'ERROR: invalid number of horizontal shifts');
                value=reshape(value,1,[]);
            end
            object.HorizontalShift=value;
        end
        function set.HorizontalScale(object,value)
            if isempty(object.HorizontalScale)
                object.HorizontalScale=value;
                return
            end
            assert(isnumeric(value) && all(isfinite(value)) && all(value > 0),...
                'ERROR: invalid horizontal scale(s)');
            if isscalar(value)
                value=repmat(value,size(object.HorizontalScale));
            else
                assert(numel(value) == numel(object.HorizontalSscale),...
                    'ERROR: invalid number of horizontal scales');
                value=reshape(value,1,[]);
            end
            object.HorizontalScale=value;
        end
        function set.VerticalShift(object,value)
            if isempty(object.VerticalShift)
                object.VerticalShift=value;
                return
            end
            assert(isnumeric(value) && all(isfinite(value)),...
                'ERROR: invalid vertical shift(s)');
            if isscalar(value)
                value=repmat(value,size(object.VerticalShift));
            else
                assert(numel(value) == numel(object.VerticalShift),...
                    'ERROR: invalid number of vertical shifts');
                value=reshape(value,1,[]);
            end
            object.VerticalShift=value;
        end
        function set.VerticalScale(object,value)
            if isempty(object.VerticalScale)
                object.VerticalScale=value;
                return
            end
            assert(isnumeric(value) && all(isfinite(value)),...
                'ERROR: invalid vertical scale(s)');
            if isscalar(value)
                value=repmat(value,size(object.VerticalScale));
            else
                assert(numel(value) == numel(object.VerticalScale),...
                    'ERROR: invalid number of vertical scales');
                value=reshape(value,1,[]);
            end
            object.VerticalScale=value;
        end
    end
    properties (SetAccess=protected, Dependent=true)
        MappedData % Four-column array  [u v du dv group]
    end
    methods
        function value=get.MappedData(object)            
            value=object.RawData;
            group=unique(value(:,5));
            for n=1:numel(group)
                index=(value(:,5) == group(n));
                x=value(index,1);
                dx=value(index,3);                
                shift=object.HorizontalShift(group(n));
                scale=object.HorizontalScale(group(n));
                u=scale*(x+shift);
                du=scale*dx;
                y=value(index,2);
                dy=value(index,4);
                shift=object.VerticalShift(group(n));
                scale=object.VerticalScale(group(n));
                v=scale*(y+shift);
                dv=scale*dy;
                value(index,1:4)=[u v du dv];   
            end                    
        end
    end
    %%
    properties
        Colormap
    end
    %% result
    properties (SetAccess=protected)
        Result % UNDER CONSTRUCTION
    end
    %%
    methods (Hidden=true)
        function object=ScatterPatch(data)
            % manage input
            if isnumeric(data)
                if numel(data) == 4
                    data=reshape(data,[1 4]);
                end
                switch size(data,2)
                    case 4
                        data(:,5)=1;                        
                        Ngroups=1;
                        object.GroupList=1;
                    case 5
                        data(:,5)=ceil(data(:,5));
                        group=data(:,5);                       
                        assert(all(group > 0),...
                            'ERROR: group numbers must be integers > 0');
                        list=unique(group);
                        Ngroups=numel(list);
                        standard=1:Ngroups;
                        if any(list ~= standard)
                            warning('Group label(s) changed to standard convention');
                            for n=1:Ngroups
                                group(group == list(n))=n;
                            end
                        end
                        data(:,5)=group;
                        object.GroupList=standard;
                    otherwise
                        error('ERROR: invalid data array');
                end
                temp=data(:,3:4);
                assert(all(temp(:) > 0),...
                    'ERROR: uncertainties must greater than zero');
                object.RawData=data;
            else
                % UNDER CONSTRUCTION
            end
            % finish setup
            enable(object);
            object.HorizontalShift=zeros(1,Ngroups);
            object.HorizontalScale=ones(1,Ngroups);
            object.VerticalShift=zeros(1,Ngroups);
            object.VerticalScale=ones(1,Ngroups);
            %
        end
    end
end