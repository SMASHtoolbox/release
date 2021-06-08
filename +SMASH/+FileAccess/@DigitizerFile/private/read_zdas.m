% 
function [signal,time]=read_zdas(filename,signal_name)

file_id = hdfh('open',filename,'read',0);
status = hdfv('start',file_id);
vgroup_ref = 4;
vdata_ref = 9;

vgroup_id = hdfv('attach',file_id,vgroup_ref,'r');
count = hdfv('ntagrefs',vgroup_id);
ndatasets = count/8;
for i=0:ndatasets-1
    vdata_id = hdfvs('attach',file_id,vdata_ref+8*i,'r');
    n = hdfvs('elts',vdata_id);
    status = hdfvs('setfields',vdata_id,'NAME');
    [name,count] = hdfvs('read',vdata_id,n);
    name = char(name{1});
    if strcmp(name,signal_name)     
        vdata_id = hdfvs('attach',file_id,(vdata_ref+5)+8*i,'r');
        n = hdfvs('elts',vdata_id);
        status = hdfvs('setfields',vdata_id,'TMIN');
        [tmin,count] = hdfvs('read',vdata_id,n);
        tmin = tmin{1};
        vdata_id = hdfvs('attach',file_id,(vdata_ref+6)+8*i,'r');
        n = hdfvs('elts',vdata_id);
        status = hdfvs('setfields',vdata_id,'TMAX');
        [tmax,count] = hdfvs('read',vdata_id,n);
        tmax = tmax{1};
        vdata_id = hdfvs('attach',file_id,(vdata_ref+7)+8*i,'r');
        n = hdfvs('elts',vdata_id);
        status = hdfvs('setfields',vdata_id,'DATA');
        [amplitude,count] = hdfvs('read',vdata_id,n);
        amplitude = amplitude{1};
        time = linspace(tmin,tmax,n);
        %ta = cat(2,time',amplitude');
        time=time(:);
        signal=amplitude(:);
        status = hdfv('end',file_id);
        status = hdfh('close',file_id);
        hdfml('closeall');
        return
    end
end
status = hdfv('end',file_id);
status = hdfh('close',file_id);
hdfml('closeall');
error('ERROR: requested signal not found');

end