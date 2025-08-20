% archiveFile Import data file into an archive
%
% UNDER CONSTRUCTION
function archiveFile(archive,varargin)

object=SMASH.FileAccess.SDAfile(archive);
import(object,varargin{:});


end