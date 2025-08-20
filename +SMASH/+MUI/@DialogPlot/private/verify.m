
function verify(object)

if ~isvalid(object) || ~ishandle(object.Figure)
    delete(object);
    error('ERROR: dialog box no longer exists');
end

end