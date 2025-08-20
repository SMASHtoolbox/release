function out = editExtract(h_edit)

editBoxes = findobj(h_edit, 'Style', 'edit');
out = nan(1, length(editBoxes));

for ii = 1:length(editBoxes)
    try
        out(ii) = eval(get(editBoxes(ii), 'String'));
    catch
    end
end

end