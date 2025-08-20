% PhysicalConstant Look up physical constant values
%
% This function provides numeric values for a variety of physical constants.
%    [value,unit]=PhysicalConstant(symbol,system);
% The first input indices the symbol associated with the physical constant,
% e.g. 'c0' is the speed of light.
%    [value,unit]=PhysicalConstant('c0','SI');
% The second input indicates the system of units, which is usually 'SI' or
% 'CGS'.
%
% Calling this function with no input our output:
%    PhysicalConstant();
% displays a list of physical constant symbols.  Specifying a symbol with
% no output:
%    PhysicalConstant(symbol);
% summarizes all available information for a particular constant.
%
% Calling this function with no input:
%    list=PhysicalConstant();
% returns structure array describing each physical constant.
%
% See also SMASH.Reference
%

%
% created November 16, 2017 by Daniel Dolan
%
function varargout=PhysicalConstant(symbol,system)

persistent list
if isempty(list)
    list=generateList();
end

% manage input
if nargin == 0
    if nargout == 0
        L=0;
        for n=1:numel(list)
            L=max(L,numel(list(n).Symbol));
        end
        format=sprintf('%%%ds : %%s\\n',L+3);
        for n=1:numel(list)
            %disp(list(n));
            fprintf(format,list(n).Symbol,list(n).Description);           
        end
    else
        varargout{1}=list;
    end
    return
elseif strcmpi(symbol,'-browse')
    browseList(list);
    return
end

assert(ischar(symbol),'ERROR: invalid symbol')

if (nargin < 2) || isempty(system)
    system='';
end
assert(ischar(system),'ERROR: invalid unit system');

% extract value and units
found=false;
for n=1:numel(list)
    if strcmpi(list(n).Symbol,symbol)
        found=true;
        data=list(n);
        break
    end
end
assert(found,'ERROR: invalid symbol');

if isempty(system)
    value=data.Value;
    unit=data.Units;
else
    found=false;
    for n=1:numel(data.System)
        if strcmpi(data.System(n),system)
            found=true;
            value=data.Value(n);
            unit=data.Units{n};
            break
        end
    end
    assert(found,'ERROR: invalid unit system');
end

% manage output
if nargout == 0
    disp(data);
else
    varargout{1}=value;
    varargout{2}=unit;
end


end

function list=generateList()

n=0;

% n=n+1;
% list(n).Symbol='alpha';
% list(n).Description='Fine structure constant';
% list(n).Value=1./repmat(137.035999,[1 2]);
% list(n).System={'SI' 'CGS'};
% list(n).Units={'' ''};

n=n+1;
list(n).Symbol='kB';
list(n).Description='Boltzmann constant';
list(n).Value=[1.380649e-23 1.380649e-16 8.617333262145e-5]; % NIST 2017
list(n).System={'SI' 'CGS' 'energy'};
list(n).Units={'J/K' 'erg/K' 'eV/K'};

n=n+1;
list(n).Symbol='c0';
list(n).Description='Speed of light';
list(n).Value=[299792458 299792458*100];
list(n).System={'SI' 'CGS'};
list(n).Units={'m/s' 'cm/s'};

n=n+1;
list(n).Symbol='epsilon0';
list(n).Description='Vacuum permittivity';
list(n).Value=8.854187817e-12;
list(n).System={'SI'};
list(n).Units={'F/m'};

n=n+1;
list(n).Symbol='G';
list(n).Description='Gravitational constant';
list(n).Value=[6.67408e-11 6.67408e-8];
list(n).System={'SI' 'CGS'};
list(n).Units={'m^3/kg^2/s^2' 'cm^3/g/s^2'};

n=n+1;
list(n).Symbol='h';
list(n).Description='Planck constant';
h=6.626070040e-34;
list(n).Value=[h h*1e7];
list(n).System={'SI' 'CGS'};
list(n).Units={'J*s' 'erg*s'};

n=n+1;
list(n).Symbol='hbar';
list(n).Description='Reduced Planck constant';
h=1.054571800e-34;
list(n).Value=[h h*1e7];
list(n).System={'SI' 'CGS'};
list(n).Units={'J*s' 'erg*s'};

n=n+1;
list(n).Symbol='hc';
list(n).Description='Planck constant times speed of light';
list(n).Value=[1.986445683e-25 1.23984193e3];
list(n).System={'SI' 'energy'};
list(n).Units={'J*m' 'eV*nm'};

n=n+1;
list(n).Symbol='mu0';
list(n).Description='Vacuum permeability';
list(n).Value=1.2566370614e-6;
list(n).System={'SI'};
list(n).Units={'N/A^2'};

n=n+1;
list(n).Symbol='me';
list(n).Description='Electron mass';
me=9.10938356e-31;
list(n).Value=[me me*1e3 0.5109989461e6];
list(n).System={'SI' 'CGS' 'energy'};
list(n).Units={'kg' 'g' 'eV'};

n=n+1;
list(n).Symbol='mp';
list(n).Description='Proton mass';
me=1.672621898e-27;
list(n).Value=[me me*1e3 938.2720813e6];
list(n).System={'SI' 'CGS' 'energy'};
list(n).Units={'kg' 'g' 'eV'};


n=n+1;
list(n).Symbol='NA';
list(n).Description='Avogadro constant';
list(n).Value=repmat(6.022140857e23,[1 2]);
list(n).System={'SI' 'CGS'};
list(n).Units={'' ''};

n=n+1;
list(n).Symbol='e';
list(n).Description='Electron charge';
list(n).Value=1.6021766208e-19;
list(n).System={'SI'};
list(n).Units={'C'};

n=n+1;
list(n).Symbol='R';
list(n).Description='Gas constant';
list(n).Value=[8.3144598 8.31445898e7];
list(n).System={'SI' 'CGS'};
list(n).Units={'J/K/mol' 'erg/K/mol'};

n=n+1;
list(n).Symbol='T0';
list(n).Description='Absolute zero';
list(n).Value=[0 -273.15];
list(n).System={'SI' 'Celcius'};
list(n).Units={'K' 'C'};

% n=n+1;
% list(n).Symbol='sigma';
% list(n).Description='Stefan-Boltzman constant';
% list(n).Value=[5.670367e-8 5.6470367e-5];
% list(n).System={'SI' 'CGS'};
% list(n).Units={'W/m^2/K^4' 'erg/cm^2/K^4'};

end

%%
function browseList(list)

fig=findall(groot,'Type','Figure','Tag','PhysicalConstantBrowser');
if ~isempty(fig)
    figure(fig(1))
    return
end

db=SMASH.MUI.Dialog('FontSize',14);
db.Name='Physical consants';
db.Hidden=true;

N=numel(list);
label=cell(N,1);
for n=1:N
    label{n}=sprintf('%s (%s)',list(n).Description,list(n).Symbol);
end

hSelect=addblock(db,'popup','Constant ',{''},30);
set(hSelect(1),'FontWeight','bold');
set(hSelect(2),'Callback',@selectConstant,'String',label);
    function selectConstant(varargin)
        choice=get(hSelect(2),'Value');
        M=numel(list(choice).Value);
        entry=cell(M,1);
        for mm=1:M
            entry{mm}=sprintf('%s: %.12g %s',list(choice).System{mm},...
                list(choice).Value(mm),list(choice).Units{mm}); 
        end
        set(hValue(2),'String',entry,'UserData',entry);
    end

hValue=addblock(db,'medit','Value',20,5);
set(hValue(1),'FontWeight','bold');
set(hValue(2),'Callback',@refresh);
    function refresh(varargin)
        set(hValue(2),'String',get(hValue(2),'UserData'));
    end

hDone=addblock(db,'button','Done');
set(hDone,'Callback',@(~,~) delete(gcbf));

selectConstant();

set(db.Handle,'Tag','PhysicalConstantBrowser','HandleVisibility','callback');
locate(db,'center');
show(db);

end