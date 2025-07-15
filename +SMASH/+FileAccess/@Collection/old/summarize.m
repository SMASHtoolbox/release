function varargout=summarize(object)

report=[];
for m=1:numel(object)
    for n=1:object(m).Sources
        new=struct('Collection',m,'Source',n,...
            'Location',object(m).Location,...
            'Prefix',object(m).Prefix,...
            'Pattern',object(m).Pattern{n},...
            'Channel',object(m).Channel{n});
        if isempty(report)
            report=new;
        else
            report(end+1)=new; %#ok<AGROW> 
        end
    end
end

if nargout == 0

else
    varargout{1}=report;
end

end