function generateWarning(object,varargin)

if strcmpi(object.Warning,'on')
    warning(varargin{:});
end

end