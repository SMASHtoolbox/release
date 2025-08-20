% listIP4 Generate a list of private IP4 addresses
%
% This function generates a list of private IP4 addresses. Full address
% specification uses four blocks, separated by periods, with integers,
% integer ranges, or wildcards.
%    address=listIP4('192.168.0.*'); everything in 192.168.0
%    address=listIP4('192.168.0.0-9'); first ten addresses in 192.168.0
%
% Partial address specification can also be used.  Missing blocks are
% filled with information from the local host.  Suppose the local host
% address is 192.168.0.1.
%    list=listIP4('*'); % list everything in 192.168.0.*
%    list=listIP4('*.1'); % list everything in 192.168.*.1
% 
% See also SMASH.System, localhost, ping
%

%
% created April 20, 2017 by Daniel Dolan (Sandia National Laboratories
%   

function list=listIP4(request)

% manage input
errmsg='ERROR: invalid request';
if nargin < 1
    request='*';
end
assert(ischar(request),errmsg);
request=strtrim(request);

% scan input
block={};
while numel(request) > 0
    block{end+1}=readBlock; %#ok<AGROW>
end
    function result=readBlock() 
        if request(1)=='*'
            start=0;
            stop=255;
            request=request(2:end);
        else
            [start,count,~,next]=sscanf(request,'%d',1);
            assert(count == 1,errmsg);
            request=request(next:end);
            if isempty(request) || request(1)=='.'
                stop=start;
            elseif request(1) == '-'                
                request=request(2:end);
                [stop,~,~,next]=sscanf(request,'%d',1);
                request=request(next:end);
            else
                error(errmsg);
            end
        end
        if isempty(request)
            % do nothing
        elseif request(1) == '.'
            request=request(2:end);
        else
            error(errmsg)
        end
        result=[start stop];       
    end

% fill in missing blocks
local=SMASH.System.localhost();
local=sscanf(local','%d.%d.%d.%d');
master=cell(1,4);
for k=1:4
    master{k}=repmat(local(k),[1 2]);
end
master=master(end:-1:1);
M=numel(master);
assert(numel(block) <= M,errmsg);

N=1;
block=block(end:-1:1);
for k=1:M
    if numel(block) < k
        block{k}=master{k};
    end
    N=N*numel(block{k}(1):block{k}(2));
end
block=block(end:-1:1);

% generate list
list=cell(N,1);
k=0;
for m1=block{1}(1):block{1}(2)
    for m2=block{2}(1):block{2}(2)
        for m3=block{3}(1):block{3}(2)
            for m4=block{4}(1):block{4}(2)
                k=k+1;
                list{k}=sprintf('%d.%d.%d.%d',m1,m2,m3,m4);
            end
        end
    end
end


end