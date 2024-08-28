% private function to verify numeric scalars
function valid=testNumber(in)

valid=false;
if isnumeric(in) && isscalar(in)
    valid=true;
end

end