% process analysis options, converting name-value pairs to a structure
function option=processOptions(varargin)

option=struct('JunkChance',0.01,'Cutoff',-inf,'Plot','on');
option=SMASH.Developer.options2struct(option,varargin{:});

J=option.JunkChance;
assert(testNumber(J) && (J > 0) &&  (J < 1),...
    'ERROR: junk chance must be between zero and 1');
if strcmpi(option.Plot,'on')
    option.Plot=true;
elseif strcmpi(option.Plot,'off')
    option.Plot=false;
else
    error('ERROR: plot option must be ''on'' or ''off''');
end

end