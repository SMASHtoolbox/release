function lambda = extractLambda(obj)
% extract lambda for single-crystal prediction

nonidealinput = false;
lambda = obj.lambdaDistribution;
if ischar(lambda)
    Edist = obj.EDistribution;
    if isnumeric(Edist)
        if numel(Edist) > 2
            lambda = obj.conversion ./ Edist(:,1);
        else
            E = obj.E;
            lambda = obj.conversion ./ [E+Edist E-Edist];
        end
    else
        nonidealinput = true;
    end
elseif isnumeric(lambda)
    if numel(lambda) == 1
        lambda = obj.lambda + lambda * [-1 1];
    else
        lambda = lambda(:,1);
    end
else
    nonidealinput = true;
end

if nonidealinput
    lambda = obj.lambda;
    warning(['Single-crystal predictor requires ', ...
        'numerical distributions - only using value in ', ...
        'obj.source.lambda, which may be too restrictive'])
end
end