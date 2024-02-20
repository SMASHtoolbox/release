% Thumbnail class
%
% This class organizes axes objects into a collection of thumbnails with
% one primary axes.  This arrangement emphasizes the contents of the
% primary axis while simultaneosly showing the other axes at a reduced
% size.  Clicking on a thumbnail axes "promotes" it to the primary axes,
% demoting the previous primary axes to a thumbnail
%
% Thumbnails are created by referencing a parent object:
%    object=Thumbnail(parent);
% where the input can be a figure, uipanel, or uitab object (anything that
% can hold hold axes objects); if no input is specified, the class
% defaults to the current figure.
%
% The location and relative size of thumbail axes are adjustable
% properties.  For example:
%    object.Location='right';
%    object.Fraction=0.30;
% places thubmials to the right of the primary axes using 30% of the
% available parent size; the remaining 70% is used for the primary axes.
% Thumbnails are stacked vertically in this configuration.  
%
% See also MUI
%

%
% created August 16, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef Thumbnail < handle
   %%
   properties
       Location = 'right' % Thumbnail location ('bottom', 'top', 'left', or 'right')
       Fraction = 0.25 % Thumnail size fraction (number from 0 to <1)
       UpdateFcn % Update function (custom refresh operations)
   end
   properties (SetAccess=protected)
       Parent % Parent object (figure, uipanel, or uitab)
   end
   properties (Dependent=true,SetAccess=protected)
       Axes
   end
   %%
   methods
       function object=Thumbnail(parent)
           % manage input           
           if (nargin == 0) || isempty(parent)
               object.Parent=gcf;
           elseif isobject(parent) 
               object.Parent=ancestor(parent,{'figure' 'uipanel' 'uitab'});                                 
           else
               error('ERROR: invalid parent object');
           end
           setappdata(object.Parent,'ThumbnailObject',object);
           refresh(object);
           %set(object.Axes,'WindowButtonDownFcn',@swapAxes);
       end
   end   
   %% setters
   methods
       function set.Location(object,value)
           assert(ischar(value),'ERROR: invalid location');
           value=lower(value);
           switch value
               case {'bottom' 'top' 'left' 'right'}
                   object.Location=value;
               otherwise
                   error('ERROR: invalid location');
           end
           refresh(object);
       end
       function set.Fraction(object,value)
           assert(isnumeric(value) && isscalar(value) ...
               && (value >= 0) && (value < 1),'ERROR: invalid fraction');
           object.Fraction=value;
           refresh(object);
       end
       function set.UpdateFcn(object,value)
           assert(isempty(value) || isa(value,'function_handle'),...
               'ERROR: invalide update function');
           object.UpdateFcn=value;
       end
   end
   %% getters
   methods
       function value=get.Axes(object)
           value=get(object.Parent,'Children');
           keep=false(size(value));
           for n=1:numel(value)
               type=get(value(n),'Type');
               if strfind(type,'axes')
                   keep(n)=true;
               end
           end
           value=value(keep);
           value=value(end:-1:1);
       end
   end
end