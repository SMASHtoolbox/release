% READCIF - extract lattice parameters and atom locations from .cif file
%
% This method extracts lattice parameters and atom locations from a
% crystallographic input file (cif). WARNING: This method cannot handle
% cifs describing incommensurate lattices.
%
% Usage:
%   >> obj = readCIF(obj, fileName)
%
% created May, 2023 by Nathan Brown
%
function obj = readCIF(obj, fileName)

%% read file

fid = fopen(fileName);
line = fgetl(fid);
pos = {};
xyzInd = [nan nan nan];
count = 1;
atomSites = {};

% get unit lattice parameters

lineEnds = ' (';

while ~isnumeric(line)
    if contains(line, '_cell_angle_alpha')
        alpha = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, '_cell_angle_beta')
        beta = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, '_cell_angle_gamma')
        gamma = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, '_cell_length_a')
        a = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, '_cell_length_b')
        b = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, '_cell_length_c')
        c = str2double(strtok(fliplr(strtok(fliplr(line))), lineEnds));
    elseif contains(line, 'xyz')
        line = fgetl(fid);
        break
    end
    line = fgetl(fid);
end

% check that we didn't reach end of file

if isnumeric(line)
    error('.cif file is missing data or contains unexpected formatting');
end

% collect symmetry positions

while contains(line, ',')
    pos{end+1} = line;
    line = fgetl(fid);
end

% collect atom positions

while ~contains(line, 'loop')
    line = fgetl(fid);
end
line = fgetl(fid);

multFlag = false;
calcFlag = false;
occupFlag = false;

while contains(line, 'atom_site')
    if contains(line, 'site_label')
        labelInd = count;
    elseif contains(line, 'symmetry_multiplicity')
        multFlag = true;
        multInd = count;
    elseif contains(line, 'calc_flag')
        calcFlag = true;
        calcInd = count;
    elseif contains(line, 'fract_x')
        xyzInd(1) = count;
    elseif contains(line, 'fract_y')
        xyzInd(2) = count;
    elseif contains(line, 'fract_z')
        xyzInd(3) = count;
    elseif contains(line, 'occupancy')
        occupFlag = true;
        occupInd = count;
    end
    line = fgetl(fid);
    count = count + 1;
end

while ~isnumeric(line) && ~contains(line, '_')
    atomSites{end+1} = line;
    line = fgetl(fid);
end

% close file

fclose(fid);

% remove empty atom sites caused by rows of blank spaces

badInd = cellfun(@length, atomSites) < 3;
atomSites(badInd) = [];

if all(badInd)
    error('CIF reader failed to find any atom sites')
end

%% parse findings

numAtoms = length(atomSites);
xyz = nan(numAtoms, 3);
label = cell(numAtoms, 1);
mult = nan(numAtoms, 1);
calc = cell(numAtoms, 1);
occup = ones(numAtoms, 1);

% extract atom labels and locations

for ii = 1:numAtoms
    strArr = split(strtrim(atomSites{ii}));
    
    xVal = strtok(strArr{xyzInd(1)}, lineEnds);
    yVal = strtok(strArr{xyzInd(2)}, lineEnds);
    zVal = strtok(strArr{xyzInd(3)}, lineEnds);
    
    xyz(ii, 1) = str2double(xVal);
    xyz(ii, 2) = str2double(yVal);
    xyz(ii, 3) = str2double(zVal);
    
    label(ii) = strArr(labelInd);
    
    if multFlag
        mult(ii) = round(str2double(strArr{multInd}));
    end
    
    if calcFlag
        calc(ii) = strArr(calcInd);
    else
        calc(ii) = {'d'};
    end
    
    if occupFlag
        occup(ii) = str2double(strArr{occupInd});
    end
    
end

% get rid of dummy atoms

dummyInd = strcmpi(calc, 'dum');
xyz(dummyInd, :) = [];
label(dummyInd) = [];
if multFlag
    mult(dummyInd) = [];
end
if occupFlag
    occup(dummyInd) = [];
end

% adjust labels to match expected output format and to include site
% occupancies

for ii = 1:length(label)
    newLabel = label{ii};
    newLabel(newLabel >= '0' & newLabel <= '9') = [];
    newLabel(newLabel == '+' | newLabel == '-') = [];
    newLabel(1) = upper(newLabel(1));
    if length(newLabel) > 1
        newLabel(2) = lower(newLabel(2));
    end
    if length(newLabel) > 2
        error(['Found unexpected atom label: ', label{ii}]);
    end
    newLabel = [newLabel, '_', num2str(occup(ii))];
    label{ii} = newLabel;
end
    
% extract eName, uvw, and g (treat elements with different occupancies as
% separate elements altogether)

[eName, ia, ic] = unique(label);
uvw = cell(1, length(eName));
g = occup(ia);

for ii = 1:size(xyz, 1)
    
    uvw_instance = nan(length(pos), 3);
    x = xyz(ii,1);
    y = xyz(ii,2);
    z = xyz(ii,3);
    for jj = 1:length(pos)
        strArr = split(strtrim(pos{jj}), {',', ' '});
        badInd = [];
        for kk = 1:length(strArr)
            if ~(contains(strArr{kk}, 'x') || contains(strArr{kk}, 'y') || ...
                    contains(strArr{kk}, 'z'))
                badInd(end+1) = kk;
            else
                strArr{kk} = erase(strArr{kk},"'");
            end
        end
        strArr(badInd) = [];
        uvw_instance(jj, :) = [eval(lower(strArr{1})), ...
            eval(lower(strArr{2})), eval(lower(strArr{3}))];
    end
    
    % translate all values so that they're in the unit cell and then remove
    % redundant positions (necessary due to inconsistencies and
    % redundancies inherent in CIF atom positioning)
    
    uvw_instance(uvw_instance < 0) = uvw_instance(uvw_instance < 0) - ...
        floor(uvw_instance(uvw_instance < 0));
    uvw_instance(uvw_instance >= 1) = uvw_instance(uvw_instance >= 1) - ...
        floor(uvw_instance(uvw_instance >= 1));
    
    uvw_instance = uniquetol(uvw_instance, 2e-2, 'ByRows', true);
    
    % check mismatch between atoms found and atoms CIF file says should be
    % in the unit cell
    
    if multFlag && mult(ii) ~= size(uvw_instance, 1)
        warning('Atom number mismatch for atom %d', ii)
    end
    
    % add this instance to the proper entry in uvw (sans redundancies)
    
    uvw{ic(ii)} = uniquetol([uvw{ic(ii)}; uvw_instance], 2e-2, 'ByRows', ...
        true);
end

% remove site occupancies from eName entries

for ii = 1:length(eName)
    eName{ii}(strfind(eName{ii},'_'):end) = [];
end

%% populate object

obj.crystal.lengths = [a, b, c];
obj.crystal.angles = [alpha, beta, gamma];
obj.crystal.elementNames = eName;
obj.crystal.elementLocations = uvw;
obj.crystal.elementOccupancies = g;
obj.crystal.CIF = fileName;

% generate unit cell

obj = generateUnitCell(obj);
end