function GeneralOptions(varargin)

% handle input
fig=varargin{3};
updatefunc=varargin{4};

% access data
data=get(fig,'UserData');

% prompt user
label={'Wavelength:','Velocity scale factor:','Velocity level offset:'};
default={data.wavelength, data.vscale, data.vlevel};
button=[];
options.root=fig;
options.location='center';
answer=datadlg('General parameters',label,default,button,options);
if isempty(answer)
    return
end
wavelength=sscanf(answer{1},'%g',1);
vscale=sscanf(answer{2},'%g',1);
vlevel=sscanf(answer{3},'%g',1);
if isempty(wavelength) || isempty(vscale)
    GeneralOptions([],[],varargin{:});
    return    
end

% look for changes
change=(data.wavelength~=wavelength)|(data.vscale~=vscale)|(data.vlevel~=vlevel);
if change
    %data.update.experimentSTFT=true;
    %data.update.history=true;
    data.update.experimentVariable=true;
    data.wavelength=wavelength;
    data.vscale=vscale;
    data.vlevel=vlevel;
    set(fig,'UserData',data);
    feval(updatefunc,fig);
end