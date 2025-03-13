% WindowButton : store/reset window button state and pointers
%
% Usage:
% >> WindowButton(fig,'store');
% >> WindowButton(fig,'recall');
function WindowButton(fig,operation)

field={...
    'Pointer' 'PointerShapeCData' 'PointerShapeHotSpot' ...
    'WindowButtonDownFcn' 'WindowButtonUpFcn' 'WindowButtonMotionFcn'
    };
switch operation
    case 'store'
        % turn off standard modes
        zoom(fig,'off');
        pan(fig,'off');
        datacursormode(fig,'off');
        rotate3d(fig,'off');
        brush(fig,'off');
        % turn off custom modes
        autoscale(fig,'off');
        tightscale(fig,'off');
        manualscale(fig,'off');
        clone(fig,'off');
        ROIstatistics(fig,'off');
        overlay(fig,'off');
        % probe and store current state
        for n=1:numel(field)
            setappdata(fig,field{n},get(fig,field{n}));
        end
        set(fig,'Pointer','crosshair',...
            'WindowButtonDownFcn','',...
            'WindowButtonUpFcn',@callback,...
            'WindowButtonMotionFcn','');
    case 'recall'
        if ~isappdata(fig,'Pointer')
            return
        end
        for n=1:numel(field)
            value=getappdata(fig,field{n});
            set(fig,field{n},value);
        end
end
refresh(fig);

end