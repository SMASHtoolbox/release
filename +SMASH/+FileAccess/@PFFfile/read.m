% read Read PFF dataset
%
% This method reads a dataset from a PFF file.
%    >> output=read(object,[dataset]);
% The optional input "dataset" is an integer specifying which dataset will
% read (default is 1). The output is a structure that depends on the
% dataset type.
%
% See also PFFfile, probe, select, write
%

%
% created January 27, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function data=read(object,dataset)

% handle input
if (nargin<2) || isempty(dataset)
    dataset=1;
end
assert(isnumeric(dataset),'ERROR: pff dataset are accessed by number');

% error checking
table=probe(object);
if (dataset<1) || (dataset~=round(dataset)) || (dataset>numel(table))
    error('ERROR: invalid dataset request');
end


fid=fopen(object.FullName,'r','ieee-be');
CleanObject=onCleanup(@() fclose(fid)); % automatically close file on function exit
ReadWord(fid,16); % skip file header
for k=1:dataset
    % read header
    start=ftell(fid);
    ReadWord(fid); % DFRAME
    LDS=ReadLong(fid);
    TRAW=ReadWord(fid);
    VDS=ReadWord(fid);
    ReadWord(fid); % TAPP
    ReadWord(fid,10); % RFU
    TYPE=ReadString(fid);
    TITLE=ReadString(fid);
    if k<dataset % skip to next header
        fseek(fid,start+2*LDS,'bof');
        continue
    end
    % read content
    switch TRAW
        case 0 % PFTDIR
            data=readPFTDIR(fid);
        case 1 % PFTUF3
            data=readPFTUF3(fid);
        case 2 % PFTUF1
            data=readPFTUF1(fid);                                    
        case 3 % PFTNF3            
            data=readPFTNF3(fid);                       
        case 4 % PFTNV3
            data=readPFTNV3(fid);
        case 5 % PFTVTX
            data=readPFTVTX(fid);
        case 6 % PFTIFL
           data=readPFTIFL(fid);
        case 7 % PFTNGD
            data=readPFTNGD(fid,VDS);
        case 8 % PFTNG3
            data=readPFTNG3(fid);
        case 9 % PFTNI3
            data=readPFTNI3(fid);
        otherwise
            error('ERROR: unrecognized dataset type detected');
    end
    data.TypeLabel=TYPE;
    data.Title=TITLE;
end

data.FileName=object.FullName;

end