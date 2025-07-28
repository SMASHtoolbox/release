function parameter=updateParameter(parameter,option)

% junk chance and noise threshold
JC=option.JunkChance;
ND=parameter.DistinctPeaks;

parameter.JunkChance=JC;
parameter.Threshold=-log(1-(1-JC).^(1/ND));

%
parameter.Cutoff=option.Cutoff;

end