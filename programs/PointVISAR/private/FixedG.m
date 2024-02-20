% print a number to a string with specified sigfigs
function func=FixedG(number,sigfigs)

if isempty(number)
    func='';
    return
end

if nargin<2
    sigfigs=[];
end
if isempty(sigfigs)
    sigfigs=3;
end

minwidth=7; % characters needed to display signs, decimal point, and zeros
space=1; % extra space to ensure column separation
width=sigfigs+minwidth+space;

format=['%' num2str(width) '.' num2str(sigfigs) 'g'];

func=sprintf(format,number);