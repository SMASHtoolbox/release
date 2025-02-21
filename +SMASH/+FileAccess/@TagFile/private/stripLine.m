function out=stripLine(in)

out=strtrim(in);

reference=double('%''"');

quote=[0 0]; % [single double]
for k=1:numel(out)
    value=double(out(k));
    if (value == reference(1)) && all(rem(quote,2) == 0) % comment
        out=strtrim(out(1:k-1));
        return
    elseif value == reference(2) % single quote
        quote(1)=quote(1)+1;
    elseif value == reference(3) % double quote
        quote(2)=quote(2)+1;
    end    
end

assert(all(rem(quote,2) == 0),'ERROR: unmatched quotes');
