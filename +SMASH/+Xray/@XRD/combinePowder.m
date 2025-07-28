% COMBINEPOWDER - combine and sort raw powder diffraction results
%
% This method combines and sorts raw powder diffraction results according
% to approximately the same methodology employed by VESTA (though this
% method forces combination of same d-spacing/twoTheta, whereas VESTA
% does not)
%
% Usage:
%   >> obj = combinePowder(obj)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = combinePowder(obj)

% eliminate F and F_abs - combining these is ambiguous

obj.prediction.F = [];
obj.prediction.F_abs = [];

% combine prediction - twoTheta must be the same to be combined

[obj.prediction.twoTheta, ia, ic] = uniquetol(obj.prediction.twoTheta, ...
    obj.prediction.combinationTolerance);
obj.prediction.d = obj.prediction.d(ia);
obj.prediction.I = accumarray(ic, obj.prediction.I);
obj.prediction.I = obj.prediction.I/max(obj.prediction.I);
obj.prediction.m = accumarray(ic, ones(size(ic)));

% find representative hkl

obj.prediction.hkl = representhkl(obj.prediction.hkl, ic, numel(ia));

end

function hkl = representhkl(hklIn, ic, len)

% select corresponding representative hkl and compute m
%
% hkl selection order (trying to guess what VESTA does):
% 1) Fewest negatives
% 2) Smallest abs(h) + abs(k) + abs(l)
% 3) Greatest positive h
% 4) Greatest positive k
% 5) Greatest positive l
% 6) Greatest abs(h)
% 7) Greatest abs(k)
% 8) Greatest abs(l)
%
% this might need some re-tooling: what to do if no positive h?

hkl = nan(len, 3);

for ii = 1:len
    ind = ic == ii;
    hkl_ii = hklIn(ind,:);
    notNegativeNum = sum(hkl_ii > -0.5, 2);
    hkl_ind = notNegativeNum == max(notNegativeNum);
    if nnz(hkl_ind) > 1
        hkl_sum = sum(abs(hkl_ii),2);
        hkl_ind = hkl_ind & hkl_sum == min(hkl_sum(hkl_ind));
        if nnz(hkl_ind) > 1
            positiveh = hkl_ind & hkl_ii(:,1) > 0;
            if any(positiveh)
                positiveh = positiveh & hkl_ii(:,1) == ...
                    max(hkl_ii(positiveh,1));
            end
            if nnz(positiveh) == 1
                hkl_ind = positiveh;
            else
                positivek = hkl_ind & hkl_ii(:,2) > 0;
                if any(positivek)
                    positivek = positivek & hkl_ii(:,2) == ...
                        max(hkl_ii(positivek,2));
                end
                if nnz(positivek) == 1
                    hkl_ind = positivek;
                else
                    positivel = hkl_ind & hkl_ii(:,3) > 0;
                    if any(positivel)
                        positivel = positivel & hkl_ii(:,3) == ...
                            max(hkl_ii(positivel,3));
                    end
                    if nnz(positivel) == 1
                        hkl_ind = positivel;
                    else
                        hkl_ind = hkl_ind & hkl_ii(:,1) == ...
                            max(abs(hkl_ii(hkl_ind,1)));
                        if nnz(hkl_ind) > 1
                            hkl_ind = hkl_ind & hkl_ii(:,2) == ...
                                max(abs(hkl_ii(hkl_ind,2)));
                            if nnz(hkl_ind) > 1
                                hkl_ind = hkl_ind & hkl_ii(:,3) == ...
                                    max(abs(hkl_ii(hkl_ind,3)));
                                if nnz(hkl_ind) > 1
                                    hkl_ind = find(hkl_ind,1);
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    hkl(ii,:) = hkl_ii(hkl_ind,:);
end

end