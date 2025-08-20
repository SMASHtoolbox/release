% LIMIT Limit object to a region of interest
%
% This method...
%
% See also DataAccess
%

%
% created
%
function object=limit(object,varargin)

% apply limit array
N=numel(varargin);
for n=1:N
    % verify Grid and LimitIndex properties
    Grid=sprintf('Grid%d',n);
    if ~isprop(object,Grid) && isprop(object,'Grid') && (n==1)
        Grid='Grid';  
    else
        error('ERROR: %s is not a valid property for this object',Grid);
    end                
    LimitIndex=sprintf('LimitIndex%d',n);
    if ~isprop(object,LimitIndex) && isprop(object,'LimitIndex') && (n==1)
        LimitIndex='LimitIndex';  
    else
        error('ERROR: %s is not a valid property for this object',LimitIndex);
    end     
    
    
    
end




end

