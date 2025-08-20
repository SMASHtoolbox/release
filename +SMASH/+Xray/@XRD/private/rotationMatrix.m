function R = rotationMatrix(theta, vec)

% assumes degrees and provides rotation matrix about an arbitrary vector
% use like: new = old * R (where new and old are row vectors)

% this is just the transpose of the column vector version: 
% https://en.wikipedia.org/wiki/Rotation_matrix

% this is slower than Rodrigues' formula, so I now only use it for very
% simple rotations in changeObject

vec = vec/vecnorm(vec,2,2);

R = zeros(3, 3, size(theta,3));
R(1,1,:) = cosd(theta) + vec(:,1,:)^2*(1-cosd(theta));
R(2,1,:) = vec(:,1,:)*vec(:,2,:)*(1-cosd(theta)) - ...
    vec(:,3,:)*sind(theta);
R(3,1,:) = vec(:,1,:)*vec(:,3,:)*(1-cosd(theta)) + ...
    vec(:,2,:)*sind(theta);
R(1,2,:) = vec(:,2,:)*vec(:,1,:)*(1-cosd(theta)) + ...
    vec(:,3,:)*sind(theta);
R(2,2,:) = cosd(theta) + vec(:,2,:)^2*(1-cosd(theta));
R(3,2,:) = vec(:,2,:)*vec(:,3,:)*(1-cosd(theta)) - ...
    vec(:,1,:)*sind(theta);
R(1,3,:) = vec(:,3,:)*vec(:,1,:)*(1-cosd(theta)) - ...
    vec(:,2,:)*sind(theta);
R(2,3,:) = vec(:,3,:)*vec(:,2,:)*(1-cosd(theta)) + ...
    vec(:,1,:)*sind(theta);
R(3,3,:) = cosd(theta) + vec(:,3,:)^2*(1-cosd(theta));

end