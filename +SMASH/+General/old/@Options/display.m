function display(object)

%N=numel(object.Name);
%fprintf('%s object with %d options\n',class(object),N);
%if N>0
%    data=convert(object,'structure');
%    disp(data);
%end
properties(object);
methods(object);

end