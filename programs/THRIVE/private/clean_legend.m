% clean_legend : eliminates duplicate tag information in legend

function varargout=clean_legend(varargin)

[legend_h,object_h,plot_h,text_strings]=legend(varargin{:});
set(object_h,'Tag',''); % remove legend tags (avoids multiple tag issues)

% handle output
if nargout>0
    varargout{1}=legend_h;
end
if nargout>1
    varargout{2}=object_h;
end
if nargout>2
    varargout{3}=plot_h;
end
if nargout>3
    varargout{4}=text_strings;
end

