function ChooseColor(~,~,edit)

color=uisetcolor;
if numel(color)==1 % user pressed cancel
    return
end
color=sprintf('%.2f ',color);
set(edit,'String',color);
%elseif all(axes_color==color) % selection won't be visible
%    return
%else
%    set(hline,'Color',color);
%end

end