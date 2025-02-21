% 
classdef SoundLibrary < handle
    properties (SetAccess=protected)
        Name = {}
        Data
    end
    methods
        function object=SoundLibrary(varargin)
            % load default sounds
            location=fullfile(matlabroot,'toolbox','matlab','audiovideo');
            file=dir(fullfile(location,'*.mat'));
            N=numel(file);            
            object.Name=cell(N,1);
            for n=1:N
                name=file(n).name;
                previous=load(fullfile(location,name));
                Fs=previous.Fs;
                previous=rmfield(previous,'Fs');
                VarName=fieldnames(previous);
                if ~isscalar(VarName)
                    continue
                end
                y=previous.(VarName{1});
                [~,object.Name{n},~]=fileparts(name);                
                temp=audioplayer(y,Fs);                 %#ok<TNMLP>
                if n == 1
                    object.Data=repmat(temp,size(object.Name));
                else
                    object.Data(n)=temp;
                end
            end       
        end
    end
end