% view View pulse train
%
% This method displays the current pulse train in a new figure.
%    view(object);
%
% See also PulseTrain
%

%
% created April 26, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object)

output=object.Output;
if nargout == 0
    view(output);
else
    varargout=cell(1,nargout);
    [varargout{:}]=view(output);
end

bound(1)=min(output.Data);
bound(2)=max(output.Data);

L=bound(2)-bound(1);
bound=bound+[-1 +1]*L/10;
if diff(bound) > 0
    ylim(bound);
end

end