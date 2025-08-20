% UNDER CONSTRUCTION

function value=getAddress(object)

if (nargin < 1) || isempty(index)
    browser=getBrowser();
elseif SMASH.General.testNumber(browser,'positive','integer','notzero')
    
else
    % TO DO
end

 list=matchClass(browser,'TextField');
 value=char(list{1}.getText());

end