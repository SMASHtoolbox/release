function func=EditBoxNum2Str(number)

sigfigs=6;
format=formatG(sigfigs);
func='';

for ii=1:numel(number)
    temp=sprintf(format,number(ii));
    temp=sscanf(temp,'%s');
    if ii == 1
        func = [func temp];
    else
        func=[func ' ' temp];
    end
end