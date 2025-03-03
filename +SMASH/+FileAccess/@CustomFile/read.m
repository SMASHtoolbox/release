% READ Read from a CustomFile object
%
%    >> output=read(object);
%
% See also FileAccess, select
%

%
function output=read(object)

if ~exist(object.FullName,'file')
    error('ERROR: file does not exist');
end

output.FileName=object.FileName;
output.Format=object.Format;
switch lower(object.Format)
    case 'oceanoptics'
        [wavelength,counts,rate,header]=OceanOptics(object.FullName);
        output.Wavelength=wavelength;
        output.Measurement=counts;
        output.Rate=rate;
        output.Header=header;
    case 'optronicslab'
        [lambda,measurement,header]=OptronicLab(object.FullName);
        output.Wavelength=lambda;
        output.Measurement=measurement;
        output.Header=header;        
    case 'optronicslabdump'
        % UNDER CONSTRUCTION
        [data,header]=OptronicLabDump(object.FullName);
        output.Data=data;
        output.Header=header;
end

end