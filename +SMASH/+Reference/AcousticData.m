% UNDER CONSTRUCTION
% AcousticData Look up acoustic data
%
% This function provides acoustic data for various materials.  The calling
% syntax is:
%    [data,name]=AcousticData(pattern);
% where the input "pattern" is search pattern.  Data from any material
% matching this pattern is returned as function outputs or printed in the
% command window (if no output is requested). If no pattern is specified,
% the user is prompted to select a material from an interactive dialog box.
%
% The output "data" is a four-column array.  The first column contains
% longitudinal sound speed (km/s), while the second column contains transverse
% sound speed (km/s); NaN values in the second column indicate that transverse
% sound speed data is not available, which is the case for all
% liquids/gasses and some solid materials.  The third column is the
% material density (g/cc) associated the the sound speed data.  The
% fourth column is the associated temperature (C), if available.
%
% The output "name" is a cell array of names for all materials that match
% the search pattern (or the interactively selected material).  Each match
% corresponds to one row of the "speed" array.  Generic patterns, such as
% 'steel', match a number of material entries, so users should verify that
% the requested sound speed matches the alloy/composition/condition of
% interest.
%
% See also SMASH.Reference

%
% created June 4, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=AcousticData(pattern)

%% store data for quick access
persistent data material group
if isempty(data)
    fprintf('Loading acoustic data...');
    data=nan(0,4); % T cL cT rho
    material={};
    group=[];
    location=fileparts(mfilename('fullpath'));
    source=fullfile(location,'data','AcousticData.xlsx');
    sheet={'Solids' 'Plastics' 'Rubber' 'Liquids' 'Body Tissue' 'Gasses'};
    for k=1:numel(sheet)
        [~,~,raw]=xlsread(source,sheet{k},'','basic');
        start=1;
        for m=1:size(raw,1)
            if strncmp(raw{m,1},sheet{k},numel(sheet{k}))
                start=m+1;
                break
            end
        end
        raw=raw(start:end,:);
        name=raw(:,1);
        keep=true(size(name));
        for m=1:numel(name)
            if isnan(name{m})
                keep(m)=false;
            end
        end
        name=name(keep);        
        switch sheet{k}
            case {'Solids' 'Plastics' }
                block=raw(keep,[2 3 5 11]);
            case {'Rubber'}
                block=raw(keep,[2 3 3 5]);
                for m=1:size(block,1)
                    block{m,3}=nan;
                end
            case {'Liquids' 'Gasses'}
                block=raw(keep,[2 3 3 6]);
                for m=1:size(block,1)
                    block{m,3}=nan;
                end
            case 'Body Tissue'
                block=raw(keep,[2 2 2 3]);
                for m=1:size(block,1)
                    block{m,1}=nan;
                    block{m,3}=nan;
                end
        end
        % fix table quirks
        for m=1:size(block,1)
            name{m}=strtrim(name{m});
            if isnumeric(block{m,1})
                continue
            end
            temp=strtrim(block{m,1});
            if isempty(temp)
                block{m,1}=nan;
                continue
            end            
            value=sscanf(temp,'%g',1);
            if strcmpi(temp(end),'K')
                block{m,1}=value-273.15;
            elseif strcmpi(temp(end),'F')
                block{m,1}=(value-32)/1.80;
            else
                try
                    block{m,1}=sscanf(temp,'%g',1);
                catch
                    error('ERROR: unable to read temperature for "%s"',name{m});
                end
            end            
        end
        data=[data; cell2mat(block)]; %#ok<AGROW>
        material=[material; name]; %#ok<AGROW>
        group=[group; repmat(k,size(name))]; %#ok<AGROW>
    end
    data=data(:,[2 3 4 1]); % [cL cT rho0 T0]
    fprintf('complete (%d records)\n',numel(material));
end   

%% manage input
if (nargin == 0) || isempty(pattern)
    error('ERROR: interactive selection is not ready');
    %index=chooseMaterial(material,group);
else
    assert(ischar(pattern),'ERROR: invalid search pattern');
    index=SMASH.General.matchPattern(material,pattern);
    index=find(index);
    assert(~isempty(index),'ERROR: search pattern does not match any material');
end

%% manage output
if nargout == 0
    temp=data(index,:);
    temp=table(material(index),temp(:,1),temp(:,2),temp(:,3),temp(:,4),...
        'VariableNames',{'Material' 'Longitudinal' 'Transverse' 'Density' 'Temperature'});
    disp(temp);
else
    varargout{1}=data(index,:);
    varargout{2}=material(index);
end

end

%%
function index=chooseMaterial(material,group)

master=1:numel(material);

% create dialog box...

end