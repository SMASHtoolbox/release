function flipImage(object,direction)

if isempty(object.Image)
    return
end

assert(ischar(direction),'ERROR: invalid flip direction');
switch lower(direction)
    case 'vertical'
        object.Image=object.Image(end:-1:1,:,:);
    case 'horizontal'
        object.Image=object.Image(:,end:-1:1,:);
    otherwise
        error('ERROR: %s is not a valid flip direction');
end

end