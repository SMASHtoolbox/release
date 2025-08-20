function object=crop(object,varargin)

try
    object.Measurement=crop(object.Measurement,varargin{:});
catch ME
    throwAsCaller(ME);
end

end