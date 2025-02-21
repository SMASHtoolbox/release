function createListener(object)

L=addlistener(object.Edit,'String','PreSet',@adjustBox);

    function adjustBox(varargin)
        temp=object.Edit.String;
        rows=size(temp,1);
        %if temp <= object.Rows
            
        %else
            
        %end
        
    end

end