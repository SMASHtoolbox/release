% BLUR Reduce sharp isomesh variations
%
% This method "blurs" the isomesh of a Distortion object, reducing
% high-frequency spatial variations.  Two types of blurring are supported.
%    >> new=blur(object,'local'); % default choice
%    >> new=blur(object,'global',[order]);
% Local blurring replaces each mesh point by the intersection its nearest
% neighbors; points on the mesh boundary are unaffected.  Global blurring
% replaces replaces every point with the intersection of polynomial curves
% generated from the existing mesh points.  Straight lines are used by
% default, but higher order polynomials can also be specified.
%
% See also Distortion, apply, locate, visualize
%

%
% created January 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=blur(object,mode,varargin)

% handle input
if (nargin<2) || isempty(mode)
    mode='local';
end

switch lower(mode)
    case 'local'
        object=blurLocal(object);
    case 'global'
        object=blurGlobal(object,varargin{:});
    otherwise
        error('ERROR: invalid blur mode');
end
object=remesh(object);

end