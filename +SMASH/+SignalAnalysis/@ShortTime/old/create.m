function object=create(object,varargin)

Narg=numel(varargin);
if (Narg==1) && isa(varargin{1},'SMASH.SignalAnalysis.Signal')
    object=reset(object,varargin{1}.Grid,varargin{1}.Data);    
    %name=properties(object);
    mc=metaclass(object);
    for n=1:numel(mc.PropertyList)
        name=mc.PropertyList(n).Name;
        if strcmpi(name,'Grid') || strcmpi(name,'Data')
            continue
        end
        try
            object.(name)=varargin{1}.(name);
        catch
            continue
        end
    end    
else
    object=create@SMASH.SignalAnalysis.Signal(object,varargin{:});    
    object.Name='ShortTime object';
    object.GraphicOptions.Title='ShortTime object';
    object.GridLabel='Time';
    object.DataLabel='Signal';
end

end