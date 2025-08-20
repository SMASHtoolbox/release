% USAF1951 1951 USAF resolution target class
%
% This class describes the 1951 USAF resolution target often used for
% spatial calibration.  Information about specific elements is avaialable
% after object creation.
%    object=USAF1951();
%    value=getWidth(object,group,element);
% Valid group numbers run from -2 to +9, although not all physical targets
% contain the entire rane.  Element numbers run from +1 to +6 in each
% group.
%
% See also SMASH.ImageAnalysis
%
classdef USAF1951
    properties (SetAccess=protected)
        Groups = -2:9 % Group numbers (-2 to +9)
        Elements = 1:6 % Element numbers (+1 to +6)
        LineDensities % Line pair densities (1/mm)
        LineWidths    % Line widths (mm)
    end
    %%
    methods (Hidden=true)
        function object=USAF1951(varargin)
            location=fileparts(mfilename('fullpath'));
            file=fullfile(location,'pairs.txt');
            raw=SMASH.FileAccess.readFile(file,'column');
            object.LineDensities=raw.Data(:,2:end);
            file=fullfile(location,'widths.txt');
            raw=SMASH.FileAccess.readFile(file,'column');
            object.LineWidths=raw.Data(:,2:end)/1000;
        end
        function [row,column]=verify(object,group,element)
            assert(nargin == 3,'ERROR: group and element must be specified');
            assert(isnumeric(group) && isscalar(group)...
                && any(group == object.Groups),'ERROR: invalid group number')
            assert(isnumeric(element) && isscalar(element)...
                && any(element == object.Elements),'ERROR: invalid element number')
            row=element;
            column=find(group == object.Groups);      
        end
    end
    %%   
    methods
        % getDensity Get line pair density
        %
        % This method gets a specified line-pair density.
        %    value=getPair(object,group,element);
        % The output "value" has units of 1/mm.
        %
        % See also USAF1951, getWidth
        function value=getDensity(object,varargin)
            try
                [row,column]=verify(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end           
            value=object.LineDensities(row,column);
        end
        % getWidth Get line width
        %
        % This method gets a specified line width.
        %    value=getWidth(object,group,element);
        % The output "value" has units of mm
        %
        % See also USAF1951, getDensity
        function value=getWidth(object,varargin)
            try
                [row,column]=verify(object,varargin{:});
            catch ME
                throwAsCaller(ME);
            end
            value=object.LineWidths(row,column);
        end
    end
end