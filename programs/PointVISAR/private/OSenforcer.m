% OSenforcer : enforce operating system separators
%
% Usage:
% out=OSenforcer(in); converts '\' and '/' to local convention


% created 1/21/2007 by Daniel Dolan
function out=OSenforcer(in)

out=in;
ii=(in=='/')|(in=='\');
out(ii)=filesep; 