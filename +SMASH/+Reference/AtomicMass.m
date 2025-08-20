% AtomicMass Look up atomic mass
%
% This function looks up atomic mass [g/mol] by element name or symbol.
%    mass=AtomicMass('Cu');
%    mass=AtomicMass('copper');
% Note that symbols are treated in a case-sensitive manner while names are
% not, e.g. 'cu' is not a valid symbol but 'Copper' is a valid name.
%
% Specific isotopes may be specified with a dash.
%    mass=AtomicMass('C-12'); % carbon 12
%    mass=AtomicMass('carbon-14'); % carbon 14
% Standard masses (based on relative abundance) are given when no
% particular isotope is requested.  Heavier elements (Z > 92) return NaN
% for the standard mass as the isotopes have no natural abundances.
%
% Interactive requests can be done for elements or isotopes.
%     mass=AtomicMass('-element');
%     mass=AtomicMass('-isotope')
%
% Data obtained from http://physics.nist.gov/Comp.
%
% See also SMASH.Reference

%
% created November 16, 2017 by Daniel Dolan
% updated February 25, 2019 by Daniel Dolan
%    -Switched from appdata to persistent variables
%
function [mass,abundance,ID]=AtomicMass(varargin)

% load data as needed
persistent data
if isempty(data)
    fprintf('Loading atomic data table...');
    location=mfilename('fullpath');
    location=fileparts(location);
    %
    NameFile=fullfile(location,'data','Elements.txt');
    NameTable=readtable(NameFile);         
    %
    MassFile=fullfile(location,'data','AtomicData.txt');
    assert(exist(MassFile,'file') == 2,...
        'ERROR: atomic data file not found');
    fid=fopen(MassFile,'r');    
    CU=onCleanup(@() fclose(fid));
    data=[];
    while ~feof(fid)
        temp=fgetl(fid);
        AtomicNumber=sscanf(temp,'Atomic Number = %d',1);
        if isempty(AtomicNumber)
            continue
        end
        temp=fgetl(fid);
        Symbol=sscanf(temp,'Atomic Symbol = %s',1);
        temp=fgetl(fid);
        MassNumber=sscanf(temp,'Mass Number = %g',1);
        temp=fgetl(fid);
        AtomicMass=sscanf(temp,'Relative Atomic Mass = %g',1);
        temp=fgetl(fid);
        Abundance=sscanf(temp,'Isotopic Composition = %g',1);
        if isempty(Abundance)
            Abundance=0;
        end
        temp=fgetl(fid);
        StandardMass=sscanf(temp,'Standard Atomic Weight = %g',1);
        if isempty(StandardMass)
            StandardMass=sscanf(temp,'Standard Atomic Weight = [%g,%g]',2);
            StandardMass=mean(StandardMass);
        end
        temp=struct('AtomicNumber',AtomicNumber,'MassNumber',MassNumber,...
            'Symbol',Symbol,'AtomicMass',AtomicMass,...
            'Abundance',Abundance,'StandardMass',StandardMass);
        index=cellfun(@(x) strcmp(x,Symbol),NameTable.Symbol);
        temp.Name=NameTable.Name{index};
        if isempty(data)
            data=temp;
        else
            data(end+1)=temp; %#ok<AGROW>
        end
    end
    fprintf('done\n');    
end

% manage input
if nargin == 0
    varargin{1}='-element';
end
assert(ischar(varargin{1}),'ERROR: invalid symbol');

mass=[];
switch varargin{1}
    case {'' '-element' '-isotope'}
        name=selectElement(data);
        if isempty(name)
            return
        end
        if strcmp(varargin{1},'-isotope')
            name=selectIsotope(name,data);
            if isempty(name)
                return
            end
        end
    otherwise
        name=varargin{1};
end

index=strfind(name,'-');
if isempty(index)
    number=[];
else
    number=sscanf(name(index+1:end),'%d',1);
    name=name(1:index-1);    
end

% match symbol
found=false;
for n=1:numel(data)
    if strcmp(name,data(n).Symbol) || strcmpi(name,data(n).Name)
        if isempty(number)                
            mass=data(n).StandardMass;
            abundance=NaN;
            ID=data(n).Name;
        elseif data(n).MassNumber == number
            mass=data(n).AtomicMass;
            abundance=data(n).Abundance;
            ID=sprintf('%s-%d',data(n).Name,data(n).MassNumber);
        end
        if ~isempty(mass)
           found=true;
           break
        end
    end
end
assert(found,'ERROR: %s is not a valid symbol',varargin{1});

end

%%
function name=selectElement(data)

name=cell(size(data));
for n=1:numel(data)
   name{n}=data(n).Name; 
end
name=unique(name);

selection=listdlg('ListString',name,'Name','Select element',...
    'PromptString','Select element from list:',...
    'SelectionMode','single');
if isempty(selection)
    name='';
else
    name=name{selection};
end

end

function name=selectIsotope(name,data)

keep=false(size(data));
for n=1:numel(data)
    if strcmpi(name,data(n).Name)
        keep(n)=true;
    end
end
data=data(keep);

list=cell(size(data));
for n=1:numel(data)
    list{n}=sprintf('%s-%d (%.1f%%)',...
        data(n).Name,data(n).MassNumber,data(n).Abundance*100);    
end

selection=listdlg('ListString',list,'Name','Select isotope',...
    'PromptString','Select isotope from list:',...
    'SelectionMode','single');
if isempty(selection)
    name='';
else
    name=list{selection};
end

end