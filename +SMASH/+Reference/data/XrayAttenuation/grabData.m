% 
function grabData()

location='https://physics.nist.gov/PhysRefData/XrayMassCoef/ElemTab';
buffer=tempname();

for Z=1:92
    % access remote data
    target=sprintf('%s/z%02d.html',location,Z);
    raw=webread(target);
    raw=extractAfter(raw,'ASCII format');
    raw=extractBetween(raw,'<PRE>','</PRE>');
    raw=raw{1};
    start=sscanf(raw,'%s',1);
    raw=extractAfter(extractAfter(raw,start),start);
    % isolate numeric information
    fid=fopen(buffer,'w');
    while ~isempty(raw)
        [new,~,~,next]=sscanf(raw,'%s',1);
        raw=raw(next:end);
        [~,count]=sscanf(new,'%g',1);
        if count > 0
            fprintf(fid,'%s ',new);
        end
    end        
    fprintf(fid,'%c',raw);
    fclose(fid);
    fid=fopen(buffer,'r');
    data=fscanf(fid,'%g %g %g',[3 inf]);
    fclose(fid);
    data=data(1:2,:);
    % create local file    
    info=SMASH.Reference.PeriodicTable(Z);
    data(2,:)=data(2,:)*info.StandardDensity;
    local=sprintf('z%02d.txt',Z);
    fid=fopen(local,'w');    
    fprintf(fid,'%s (Z=%d) photon attenuation\n',info.Name,Z);  
    fprintf(fid,'Energy (MeV) Attenuation (1/cm)\n');
    fprintf(fid,'%.5e %.3e\n',data);
    fclose(fid);
end