% readAttribute Read HDF5 attribute
%
% This function reads attributes from a HDF5 file.  Most of the work is
% handled by MATLAB's h5readatt function, with additional handling of
% string attributes that may be returned as cell arrays.
%

%
% created March 2, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function value=readAttribute(file,location,name)

try
    value=h5readatt(file,location,name);
catch ME
    rethrow(ME)
end

switch class(value)
    case 'cell'
        if numel(value) > 1            
            warning(...
                'WARNING: multiple attribute values detected.  Only the first value will be kept.');            
        end
        value=value{1};
        assert(ischar(value),'ERROR: invalid attribute value');
        value=deblank(value);
end

end