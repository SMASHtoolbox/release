% UNDER CONSTRUCTION
%

function extractFile(archive,varargin)

object=SMASH.FileAccess.SDAfile(archive);
export(object,varargin{:});

end