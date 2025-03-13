% GENERATEPREDICTION - predict powder and single-crystal XRD patterns
%
% This method predicts powder and single-crystal diffraction patterns.
%
% Usage:
%   >> obj = generatePrediction(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = generatePrediction(obj)

% delete existing prediction in case something fails in here

obj = deletePredictionAndResults(obj, 'p');

% parse the option

combineOp = true;
detectorOp = true;

switch obj.prediction.option
    case 'separate'
        combineOp = false;
    case 'all'
        detectorOp = false;
    case 'allseparate'
        combineOp = false;
        detectorOp = false;
end

% generate hkl
        
obj = generatehkl(obj);

% generate straight-thru prediction

obj = findStraightThruLocation(obj);

% generate prediction based on type

switch obj.prediction.type
    
    case 'powder'
        
        % set lambda
        
        obj.prediction.lambdaSol = obj.source.lambda;
        
        % find separate powder diffraction pattern
        
        obj = powderPredictor(obj);
        
        % combine powder diffraction prediction
        
        if combineOp && ~isempty(obj.prediction.twoTheta)      
            obj = combinePowder(obj);    
        end
        
        % find where the rings hit the detector
        
        if detectorOp && ~isempty(obj.prediction.twoTheta) 
            
            % extract values
            
            twoTheta = obj.prediction.twoTheta;
            s0 = obj.source.s0/norm(obj.source.s0);

            % generate s cone by rotating s0 by twoTheta about some orthogonal
            % vector and then rotating the result uniformly about s0.
            % each row represents twoTheta and each page represents a
            % different part of the cone
            % note: faster to repmat and then use built-in dot and cross

            if s0(3) == 0
                a = [0 0 1];
            else
                a = [1 1 -(s0(1)+s0(2))/s0(3)]; a = a/norm(a);
            end

            phi = permute(linspace(0,360,1000), [1 3 2]);
            s = s0.*cosd(twoTheta) + cross(a,s0,2).*sind(twoTheta) + ...
                a.*dot(a,s0,2).*(1-cosd(twoTheta));
            s0 = repmat(s0, size(s,1), 1, 1);
            s = s.*cosd(phi) + cross(s0,s,2).*sind(phi) + ...
                s0.*dot(s0,s,2).*(1-cosd(phi));
            
            % find where individual vectors hit the detector and eliminate
            % twoTheta values that don't produce any vectors that hit the
            % detector or that hit masked spots 

            obj.prediction.s = s;
            obj = findSpotLocations(obj);

            % ring fraction on detector (accounting for 0-360 redundancy)

            rho = sum(~isnan(obj.prediction.spotLocations(:,1,1:end-1)),3) / ...
                (size(obj.prediction.spotLocations,3) - 1);

            % distance along detector (making use of 0-360 redundancy)

            c = sum(sqrt(sum(diff(obj.prediction.spotLocations,1,3).^2, ...
                2)),3,'omitnan');

            % L from average linear density of points on the detector

            L = rho./c;

            obj.prediction.I = obj.prediction.I.*L;
            obj.prediction.I = obj.prediction.I / max(obj.prediction.I);

        end
        
        
    case 'single-crystal'
        
        % extract what you need from the object
        
        V = obj.crystal.volume;
        a_vec = obj.crystal.vectors(1,:);
        b_vec = obj.crystal.vectors(2,:);
        c_vec = obj.crystal.vectors(3,:);
        hkl = obj.prediction.hkl;
        s0 = obj.source.s0/norm(obj.source.s0);
        lambda = extractLambdaRange(obj);
        
        % compute reciprocal lattice and H in ijk space
        
        a_star = cross(b_vec, c_vec)/V;
        b_star = cross(c_vec, a_vec)/V;
        c_star = cross(a_vec, b_vec)/V;

        H = hkl(:,1).*a_star + hkl(:,2).*b_star + hkl(:,3).*c_star;
        
        % find lambda that satisfies elastic scattering condition - what
        % value forces a unit vector solution to a unit vector input of the
        % Laue equation?
        % elastic scattering condition given on pg. 214 in Girolami
        
        a = sum(H.^2, 2);
        b = sum(2*H.*s0, 2);
        lambdaSol = -b./a; % simplified quadratic formula for c = 0 and lambda ~= 0
        
        % only keep solutions that fall within the given wavelength range
        
        badInd = lambdaSol > max(lambda) | lambdaSol < min(lambda) | ...
            isnan(lambdaSol);
        lambdaSol(badInd) = [];
        hkl(badInd,:) = [];
        H(badInd, :) = [];
        
        % compute s
        
        s = s0 + H.*lambdaSol;
        
        % populate object
        
        obj.prediction.s = s;
        obj.prediction.lambdaSol = lambdaSol;
        obj.prediction.hkl = hkl;
        
        % find where spots hit the detector
        
        if detectorOp && ~isempty(obj.prediction.lambdaSol)
            obj = findSpotLocations(obj);
        end
        
        % find powder diffraction characteristics
        
        if ~isempty(obj.prediction.lambdaSol)
            obj = powderPredictor(obj);
        end
        
        % order prediction by I
        
        if ~isempty(obj.prediction.lambdaSol)
            [~, sortInd] = sort(obj.prediction.I, 'descend');
            obj.prediction.hkl = obj.prediction.hkl(sortInd, :);
            obj.prediction.lambdaSol = obj.prediction.lambdaSol(sortInd);
            obj.prediction.twoTheta = obj.prediction.twoTheta(sortInd);
            obj.prediction.I = obj.prediction.I(sortInd);
            obj.prediction.d = obj.prediction.d(sortInd);
            obj.prediction.F_abs = obj.prediction.F_abs(sortInd);
            obj.prediction.F = obj.prediction.F(sortInd);
            obj.prediction.s = obj.prediction.s(sortInd,:);
            if detectorOp
                obj.prediction.spotLocations = ...
                    obj.prediction.spotLocations(sortInd,:);
            end
        end
      
end

end

