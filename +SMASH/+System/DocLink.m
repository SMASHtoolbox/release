function varargout=DocLink(name,link)

temp=sprintf('<a href="matlab: doc(''%s'')">%s</a>',name,link);

if nargout == 0
    disp(temp);
else
    varargout{1}=temp;
end

end