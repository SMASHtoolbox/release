% PROBE Probe control values in a Dialog
%
% This method probes all controls in a custom dialog box whose state can be
% altered: edit boxes, check boxes, radio buttons, popup menus, and list
% boxes.
%    >> value=probe(object);
% Value are returned as cell array in the order that the objects were
% created.
%
% See also Dialog, addblock
%

% created August 2, 2013 by Daniel Dolan (Sandia National Laboratories)
function state=probe(object)

verify(object);

state=cell(0);
children=get(object.Handle,'Children');
for n=numel(children):-1:1
    type=get(children(n),'Type');
    if strcmpi(type,'uicontrol')
        switch get(children(n),'Style')
            case 'edit'
                state{end+1}=get(children(n),'String');
            case {'checkbox','radio'}
                state{end+1}=logical(get(children(n),'Value'));
            case {'popupmenu','listbox'}
                choices=get(children(n),'String');
                value=get(children(n),'Value');
                state{end+1}=choices{value};
            otherwise
                % do nothing
        end
    elseif strcmpi(type,'uitable')
        state{end+1}=get(children(n),'Data');
    end
end
end