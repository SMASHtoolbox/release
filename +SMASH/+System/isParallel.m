% isParallel Determine if parallel processing is available
%
% This function determines if parallel processing is available on the
% current system.
%    [result,workers]=isParallel();
% The output "result" is true when the Parallel Processing Toolbox is
% present *and* multiple workers are enabled.  The number of active workers
% is returned as the second ouput.

%
% See also System
%

%
% created January 7, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function [result,workers]=isParallel()

result=false;
workers=1;
try
   temp=gcp('nocreate');
   if ~isempty(temp)
       result=true;
       workers=temp.NumWorkers;
   end        
catch % MATLAB 2013a and earlier        
    if exist('matlabpool','file')
        workers=numel(gcp('nocreate'));
        if workers > 0
            result=true; % MATLAB 2013a and earlier        
        end        
    else
        
    end
end

end