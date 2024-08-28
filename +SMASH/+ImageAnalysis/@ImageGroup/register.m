%Register This method is not supported to be called by ImageGroup
%
%   If you want to apply a register to an ImageGroup, the method can be
%   called with an Image supplied as the master referene:
%       >result=register(master(Image),target(ImageGroup),mtable,ttable);
%
% see also ImageGroup, SMASH.ImageAnalysis.Image.register

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function varargout=register(varargin)

% handle input

sprintf('Register cannot be called with an ImageGroup as the Master, however Register can be applied TO an ImageGroup if an Image is supplied for the Master.')


end

