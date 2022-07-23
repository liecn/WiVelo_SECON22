function [next_point,distance] = go_to_next(antenna_coords1, antenna_coords2,T, start_point, direction1, direction2)
% NEXT_POINT = GO_TO_NEXT(ANTENNA_COORDS1, ANTENNA_COORDS2, T, STARTstart__POINT,
% DIRECTION1, DIRECTION2) computes the coordition of the next predicted
% point given the starting point and the moving direction from different
% receivers.

next_point = zeros(1,2);
a1 = (norm(antenna_coords1(2,:)-start_point)+norm(T-start_point))/2;
a2 = (norm(antenna_coords2(2,:)-start_point)+norm(T-start_point))/2;


if direction1 > 0
    c1 = norm(antenna_coords1(1,:)-T)/2;
    mid_point1 = (antenna_coords1(1,:)+T)/2;
%     a1 = a1 * scaler;
elseif direction1 == 0
    c1 = norm(antenna_coords1(2,:)-T)/2;
    mid_point1 = (antenna_coords1(2,:)+T)/2;
else
    c1 = norm(antenna_coords1(3,:)-T)/2;
    mid_point1 = (antenna_coords1(3,:)+T)/2;
%     a1 = a1 / scaler;
end

if direction2 > 0
    c2 = norm(antenna_coords2(1,:)-T)/2;
    mid_point2 = (antenna_coords2(1,:)+T)/2;
%     a2 = a2 * scaler;
elseif direction2 == 0
    c2 = norm(antenna_coords2(2,:)-T)/2;
    mid_point2 = (antenna_coords2(2,:)+T)/2;
else
    c2 = norm(antenna_coords2(3,:)-T)/2;
    mid_point2 = (antenna_coords2(3,:)+T)/2;
%      a2 = a2 / scaler;
end

syms x y;

e1 = (x-mid_point1(1))^2/a1^2+(y-mid_point1(2))^2/(a1^2 - c1^2) - 1;
e2 = (x-mid_point2(1))^2/a2^2+(y-mid_point2(2))^2/(a2^2 - c2^2) - 1;
[x,y] = solve(e1,e2,x,y,'Real',true);

for k=1:length(y)
    if double(y(k))>0
        next_point(1) = double(x(k));
        next_point(2) = double(y(k));
        break
    end
end
distance=norm(next_point-start_point);
if distance>0.15
    distance=0.15;
elseif distance<0.05
    distance=0.05;
end