function ind = radioExtract(h_radio)

for ii = 1:length(h_radio)
    if get(h_radio(ii), 'Value')
        ind = ii;
        return
    end
end

% if we don't find anything, just make it the first option:

ind = 1;
set(h_radio(ind), 'Value', 1);

end