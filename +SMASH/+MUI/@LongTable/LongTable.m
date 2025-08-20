classdef LongTable < handle
    properties (SetAccess=protected)
        Label
        Edit
        Slider
        Panel
    end
    %%
    properties
        String = ''       
    end
    properties (SetAccess=protected)
        Rows
        Columns        
    end
    properties (SetAccess=protected)%, Hidden=true)
        RowHeight
        RowMargin        
    end
    methods (Hidden=true)
        function object=LongTable(varargin)           
            % manage input
            assert(rem(nargin,2) == 0,'ERROR: unmatched name/value pair');
            option.FontSize=get(groot,'DefaultUIControlFontSize');
            option.Columns=40;
            option.Rows=10;
            option.Visible='on';
            option.Label='Label:';
            for n=1:2:nargin
                name=varargin{n};
                assert(ischar(name),'ERROR: invalid option name');
                value=varargin{n+1};
                switch lower(name)
                    case 'fontsize'
                        assert(isnumeric(value) && (value > 0),...
                            'ERROR: invalid font size');
                        option.FontSize=value;
                    case 'columns'
                        assert(isnumeric(value) && (value > 0),...
                            'ERROR: invalid number of columns');
                        option.Columns=ceil(value);
                    case 'rows'
                        assert(isnumeric(value) && (value > 0),...
                            'ERROR: invalid number of rows');
                        option.Rows=ceil(value);
                    case 'visible'
                        if strcmpi(value,'on') || strcmpi(value,'off')
                            option.Visible=lower(value);
                        else
                            error('ERROR: visible option must be ''on'' or ''off''');
                        end     
                    case 'label'
                        assert(ischar(value),'ERROR: invalid label');
                        option.Label=value;
                    otherwise
                        error('ERROR: invalid option name');
                end
            end
            % 
            object.Rows=option.Rows;
            object.Columns=option.Columns;
            object.Label=option.Label;
            % create edit box
            option=rmfield(option,{'Columns' 'Rows' 'Label'});
            temp=SMASH.General.structure2list(option);
            object.Edit=uicontrol(temp{:});
            set(object.Edit,'Style','edit','Max',2,'HorizontalAlignment','left');                   
            object.Edit.String=...
                repmat('M',[object.Rows+1 object.Columns+1]);  % avoid early scroll/wrap with extra row/column
            object.Edit.Position(3:4)=object.Edit.Extent(3:4);
            object.Edit.Position(3)=object.Edit.Position(3)+object.Edit.Position(1);
            InitialPosition=getpixelposition(object.Edit);
            object.Edit.String=repmat('M',[object.Rows object.Columns]);
            object.RowHeight=object.Edit.Extent(4)/object.Rows;
            object.RowMargin=InitialPosition(4)-object.Edit.Extent(4);                        
            object.Edit.String=object.String;
            % create panel                                    
            object.Panel=uipanel('Unit','pixels','position',InitialPosition,'BorderType','none');
            set(object.Edit,'Parent',object.Panel);
            object.Edit.Position(1:2)=1;
            % create slider
                       
            %
            createListener(object);

        end
    end
end