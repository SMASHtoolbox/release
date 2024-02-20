% DoubleInputDlg : special form of inputdlg for double precision numbers
%
% Like inputdlg, this function generates a dialog box with a number of
% fields for data input.  The number of fields is specified by the number
% of prompts specified by the user.  The output of this function is a cell
% array of doubles.  Default values may be specified by a numeric or cell array that
% is less than or equal to the number of prompts; if more default values
% are specified, they will be ignored.  The output of this function matches
% the type type of the default input; if no default is specified, output
% is returned as a numeric array.
%
% Usage:
% answer=DoubleInputDlg(prompt,title);
% answer=DoubleInputDlg(prompt,title,default);
% answer=DoubleInputDlg(prompt,title,default,sigfigs);

function func=DoubleInputDlg(prompt,title,default,sigfigs)

% input checking
if nargin<1
    prompt={};
end
if nargin<2
    title='DoubleInputDlg';
end
if nargin<3
    default=[];
end
if nargin<4
    sigfigs=[];
end

% standard values for empty input
if isempty(prompt)
    prompt{1}='Input:';
end
if isempty(sigfigs)
    sigfigs=6;
end

% prepare default values for inputdlg
NumDefault=numel(default);
for ii=1:length(prompt)
    if ii>NumDefault
        DefaultInput{ii}='';
        continue
    end    
    temp=ExtractData(default,ii);
    DefaultInput{ii}=sscanf(FixedG(temp,sigfigs),'%s');
end

NumLines=1;
answer=inputdlg(prompt,title,NumLines,DefaultInput);
if isempty(answer) % user pressed cancel/closed window
    func=default;
    return
end

% extract results from dialog
for ii=1:length(answer)
    %temp=str2double(answer{ii});
    temp=sscanf(answer{ii},'%g');
    if isempty(temp)
         msg{1}=[prompt{ii} ' input ''' answer{ii} ''' is invalid.'];
         msg{2}=['Previous value of ' DefaultInput{ii} ' used instead.'];
         temp=ExtractData(default,ii);
         handle=warndlg(msg,['Warning: invalid input for ' title]);
         uiwait(handle)
    end
    %if isnan(temp)       
        %msg{1}=[prompt{ii} ' input ''' answer{ii} ''' is not a number.'];
        %if isempty(DefaultInput{ii})
        %    %msg{2}=['Value set to 0--proceed with caution!'];
        %    %temp=0;
        %else
        %    msg{2}=['Previous value of ' DefaultInput{ii} ' used instead.'];
        %    temp=ExtractData(default,ii);
        %end
        %handle=warndlg(msg,['Warning: invalid input for ' title]);
        %uiwait(handle)
    %end
    result(ii)=temp;
end

if iscell(default)
    func=num2cell(result);
else
    func=result;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function func=ExtractData(data,element)

if isnumeric(data)
    func=data(element);
end

if iscell(data)
    func=data{element};
end