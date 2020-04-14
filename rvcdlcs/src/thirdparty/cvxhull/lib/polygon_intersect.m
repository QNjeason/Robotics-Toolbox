function [ints_x, ints_y] = polygon_intersect(poly1_x, poly1_y, poly2_x, poly2_y)
% ��������͹����εĽ��� 
% https://ridiqulous.com/find-the-intersection-of-convex-hull-using-matlab/
% poly1_x,poly1_y �ֱ�Ϊ��һ������εĸ��������x,y���꣬��Ϊ������
% poly2_x,poly2_y �ֱ�Ϊ�ڶ�������εĸ��������x,y���꣬��Ϊ������
% ********************************************************** %
% Let S be the set of vertices from both polygons.
% For each edge e1 in polygon 1
%   For each edge e2 in polygon 2
%     If e1 intersects with e2
%       1. Add the intersection point to S
% Remove all vertices in S that are outside polygon 1 or 2
% ********************************************************** %
S(:,1) = [poly1_x; poly2_x]; % ����������ε�������� S �У�˳������ν
S(:,2) = [poly1_y; poly2_y];
num = size(poly1_x, 1) + size(poly2_x, 1) + 1;
for i = 1:size(poly1_x, 1) - 1
    for j =1:size(poly2_x, 1) - 1
        X1 = [poly1_x(i); poly1_x(i+1)];
        Y1 = [poly1_y(i); poly1_y(i+1)];
        X2 = [poly2_x(j); poly2_x(j+1)];
        Y2 = [poly2_y(j); poly2_y(j+1)];
        [intspoint_x, intspoint_y] = polyxpoly(X1, Y1, X2, Y2); % �������߶ν����x,y����
        if ~isempty(intspoint_x) % �������߶��޽�����������һ���߶Σ����н����򽫽����x,y�������S��
            S(num, 1) = intspoint_x;
            S(num, 2) = intspoint_y;
            num = num + 1; % ���� S �����µ���һ��
        end
    end
end
IN = inpolygon(S(:,1), S(:,2), poly1_x, poly1_y);
S(IN == 0, :) = []; % �޳�����λ�ڶ���� A �еĶ�������
IN = inpolygon(S(:,1), S(:,2), poly2_x, poly2_y);
S(IN == 0, :) = []; % �޳�����λ�ڶ���� B �еĶ�������
S = unique(S,'rows');
if iscolinear(S)
    % �ж��Ƿ�Ϊͬһ���ȫ������
    ints_x = S(:, 1); % �õ���������εĸ�����������
    ints_y = S(:, 2);
else
    % �����ȫ������Ҳ��ͬһ�㣬��ȡ͹��
    X = S(:, 1);
    Y = S(:, 2);
    k = convhull(X, Y);
    ints_x = X(k);
    ints_y = Y(k);
end
% plot(poly1_x, poly1_y, 'r', poly2_x, poly2_y, 'b', ints_x, ints_y, 'k')