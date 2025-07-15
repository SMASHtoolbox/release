% h5trim Trim HDF dataset
%
% This function trims an existing dataset to a specified array bound.
%   h5trim(file,dataset,bound);
% Inputs "file" and "dataset" control the specified dataset to be trimmed.
% The input "bound" defines the maximum index (starting from one) for each
% array dimension.  For example, a bound of [10 inf] eliminates all rows
% after m=10 while preserving all columns.
%
% The primary application of this function is cleaning up a dataset after
% an array is overwritten by a smaller array.  Note that finite dataset
% dimensions *cannot* be reduced, i.e. trimming can only be performed in
% directions of infinite size (as defined by h5create).
%
% See also SMASH.FileAccess, h5create
% 
function h5trim(file,dataset,bound)

% manage input
assert(nargin == 3,'ERROR: three input arguments must be specified')
assert(isnumeric(bound),'ERROR: invalid trim bound');

% error checking
try
    info=h5info(file,dataset);
    bmax=info.Dataspace.Size;
    maxsize=info.Dataspace.MaxSize;
catch ME
    throwAsCaller(ME);
end

assert(numel(bound) == numel(bmax),...
    'ERROR: trim bound not consistent with dataset');
for k=1:numel(bound)
    if bound(k) > bmax(k)
        bound(k)=bmax(k);
    end    
    if isfinite(maxsize(k))
      assert(bound(k) == maxsize(k),...
          'ERROR: dimension %d size cannot be reduced in this dataset',k);
    end
end

% low level HDF5
fileattrib(file,'+w');
fid=H5F.open(file,'H5F_ACC_RDWR','H5P_DEFAULT');
did=H5D.open(fid,dataset);
H5D.set_extent(did,bound([2 1 3:end]));
H5D.close(did);
H5F.close(fid);

end