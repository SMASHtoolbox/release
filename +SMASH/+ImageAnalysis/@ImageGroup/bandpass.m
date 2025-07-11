% BANDPASS Apply bandpass filter to ImageGroup object
%
% This method iteratively calls Image.Bandpass
%
% Usage:See Image.Bandpass method for details
%
% Created by Nathan Brown (SNL) 07/2025

function object=bandpass(object,varargin)

for ii = 1:object.NumberImages
    im = bandpass(split(object,ii), varargin{:});
    object.Data(:,:,ii) = im.Data;
end

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);
end