function rotateImage(object,direction)

if isempty(object.Image)
    return
end

assert(ischar(direction),'ERROR: invalid rotate direction');
switch lower(direction)
    case 'left'
        object.Image=permute(object.Image(:,end:-1:1,:),[2 1 3]);
    case 'right'
        object.Image=permute(object.Image(end:-1:1,:,:),[2 1 3]);
    otherwise
        error('ERROR: %s is not a valid rotate direction');
end

end