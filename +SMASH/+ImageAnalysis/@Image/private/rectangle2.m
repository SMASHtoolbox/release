% RECTANGLE2 : black on white rectangle for universal visiblity

function h2=rectangle2(varargin)

h1=rectangle(varargin{:});
h2=rectangle(varargin{:});
hr=[h1 h2];

set(h1,'EdgeColor','w','LineStyle','-');
linestyle=get(h2,'LineStyle');
if strcmp(linestyle,'-')
    set(h2,'EdgeColor','k','LineStyle','--');
end
set(hr,'FaceColor','none');

hlink=linkprop(hr,{'Position','LineWidth'});
setappdata(h1,'PropertyLink',hlink);

set(hr,'DeleteFcn',@DeleteBoth);
    function DeleteBoth(src,~)
      for k=1:numel(hr)
          if hr(k)==src
              continue
          end
          delete(hr(k));
      end
    end

set(h1,'Tag','rectangle2_layer1');
set(h2,'Tag','rectangle2_layer2');

end