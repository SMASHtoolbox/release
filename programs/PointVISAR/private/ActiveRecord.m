% determine active PointVISAR record

%function [active,data]=ActiveRecord(data)
function active=ActiveRecord(data)

% active=[];
% for ii=1:numel(data)
%     if data{ii}.Active
%         if isempty(active)
%             active=ii;
%         else
%             data{ii}.Active=false;
%         end
%     end
% end

N=numel(data);
for k=1:N
    if data{k}.Active
       active=k;
       return
    end
end

if N>0
    active=N;
else
    active=[];
end