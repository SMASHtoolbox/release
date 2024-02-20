% SmartFormat : intelligent output format for numerical data
function [format,width]=SmartFormat(data,digits)

% defaults
if nargin<1
    data=[];
end
if isempty(data)
    data=0;
end

if nargin < 2
    digits = [];
end
if isempty(digits)
    digits=6;
end

% determine the proper output mode
limit=[1e-4 1e5]; % set by %g format
Dmax=max(abs(data));
Dmin=min(abs(data));
if (Dmax<limit(1)) | (Dmin>=limit(2)) % use exponential notation
    dleft=1;
    dright=digits-dleft;
    extra=7; % counts signs (2), decimal point(1), and exponent (4)
    width=digits+extra;
    format=['%+' num2str(width,'%d') '.' num2str(dright,'%d') 'e'];
else % use fixed notation
    dleft=floor(log10(Dmax))+1;
    if dleft>0
        dright=max([digits-dleft 0]);
    else
        dright=digits+abs(dleft);
    end
    extra=2; % counts sign (1) and decimal point (1)
    width=abs(dleft)+dright+extra;
    format=['%+' num2str(width,'%d') '.' num2str(dright,'%d') 'f'];
end