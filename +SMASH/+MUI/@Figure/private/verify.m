
function verify(object)

if ~isvalid(object) || ~ishandle(object.Handle)
    delete(object);
    error('ERROR: figure no longer exists');
end

end