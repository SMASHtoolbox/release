
function verify(object)

if ~isvalid(object) || ~ishandle(object.Handle)
    delete(object);
    error('ERROR: dialog box no longer exists');
end

end