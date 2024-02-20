% CreateRecord    Creates a single VISAR record with default empty fields
function func=CreateRecord(type)

% input check
if nargin<1
    type='';
end
if isempty(type)
    type='pushpull2';
end

% general parameters 
func.Type=type;
func.Label='New record';

func.Analysis='velocity';
func.VPF = 1;
%func.Delay=nan;
func.Delay=[];
%func.Dispersion=0;
func.Dispersion=[];
%func.Wavelength=nan;
func.Wavelength=[];
%func.DerivativeParams=[1 3];
func.DerivativeParams=[];

func.InitialVelocity = 0;
func.InitialTime = [-inf -inf];
%func.EllipseTime = [-inf inf];
func.ExperimentTime = [-inf inf];

func.FilterName = '';
func.FilterParams = [];

func.AddJumps = [];
func.SubtractJumps = [];
func.JumpWidth=[];

func.TimeShift = 0;
func.SignalTimeScale=1;

% configuration specific parameters
switch type
    case 'conventional'
        numsignals=3;
        func.BIMFilterName = '';
        func.BIMFilterParams = [];
        labels={'D1','D2','BIM'};
        func.Ellipse = [1 1 1 1 0];
	func.EllipseFixed = [0 0 0 0 0];
    case 'pushpull2'
        numsignals=2;
        labels={'D1','D2'};
        func.Ellipse = [0 0 1 1 0];
	func.EllipseFixed = [1 1 0 0 0];
    case 'pushpull4'
        numsignals=4;
        labels={'D1A','D1B','D2A','D2B'};
        func.Ellipse = [0 0 1 1 0];
	func.EllipseFixed = [1 1 0 0 0];
    otherwise 
        error('Unknown VISAR type!');
end
func.SignalTimeShift=repmat(0,[1 numsignals]);
func.SignalVerticalShift=repmat(0,[1 numsignals]);
func.SignalScale=repmat(1,[1 numsignals]);

% file I/O parameters
for ii=1:numsignals
    func.InputFiles{ii}='';
end
%func.OutputFile{1}='';
func.OutputFile={''};
func.OutputFileMode='compact';

% record notes (text ignored by analysis)
%func.Notes={};
func.Notes='';

% store config field names
func.ParameterFields=fieldnames(func);

% administrative parameters
func.NumSignals=numsignals;
func.SignalLabels=labels;
func.Active=true;
func.Selected=true;
func.NewRecord='true';
func.EllipseFit=false;
func.LineColor=[];

% data fields
for ii=1:numsignals
    func.RawSignalTime{ii}=[];
    func.SignalTime{ii}=[];   
    func.RawSignal{ii}=[];
    func.Signal{ii}=[];
end

% result fields
func.Time = [];
func.D={[] []};
%func.BIM = [];
func.Phase = [];
func.Contrast = [];
func.Velocity = [];
%func.Position = [];