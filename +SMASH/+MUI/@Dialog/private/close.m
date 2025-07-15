
%%
function close(obj)
% dialog.close : close the dialog
%   >> object.close;
delete(obj.Handle);
obj.Handle=[];
end