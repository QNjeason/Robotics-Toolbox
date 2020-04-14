function [I,V] = boundary_(V,s)
% boundary_ - Boundary of a set of points in 2-D or 3-D
%
%     This MATLAB function returns a vector of point indices representing a single
%     conforming 2-D boundary around the points (x,y).
%
%     k = boundary(V)
%     k = boundary(___,s) (s=0, convex hull; s=1, compact boundary)
%     [k,v] = boundary(___)

if iscolinear(V)
    if ~isempty(V)
        % ���ȫ�����߻���
        V1 = unique(V,'rows');
        % [C, ia, ic] = unique(A,'rows')
        % ��� A ���������� C = A(ia) �� A = C(ic)�� ��� A ��
        % ��������飬�� C = A(ia) �� A(:) = C(ic)�� ���ָ����
        % 'rows'ѡ��� C = A(ia,:) �� A = C(ic,:)�� ��� A ��
        % ���ʱ����� C = A(ia,:) �� A = C(ic,:)��
        Vc = sum(V1)/size(V1,1);
        V2 = round((V1-Vc)*100)/100;
    else
        V2 = V;
    end
    switch rank(V2)
        case 0
            % �ж�Ϊ��
            I = V;
        case 1
            if size(V1,1)==1
                % �ж�Ϊͬһ��
                I = 1;
            elseif size(V,1)==2
                % �ж�Ϊ����(2)
                I = [1;2;1];
            else
                % �ж�Ϊ����(>=3)
                I = furthest(V);
                I = [I(:);I(1)];
            end
        case 2
            % �ж�Ϊ����
            % ��������ȫ������������ʾ
            n = null(V1); % V*n==0˵������n��ֱ��V�е�ÿһ��Ԫ��
            o = (sum(V1)/size(V1,1))'; % oΪƽ��V��ԭ��
            z = n+o; x = V1(1,:)'-o; y = skew(z)*x; % x,y,zΪ��������ϵ��ƽ��VΪxoyƽ��
            g0 = [eye(3),zeros(3,1)]; g1 = [x(:),y(:),z(:),o(:)];
            T = e2h(g1)*e2h(g0)^-1;
            V3 = h2e(T^-1*e2h(V'))';
            I = boundary_(V3(:,1:2));          
        otherwise
            error('unknown size');
    end
else
    % MATLAB function
    if nargin<2
        I = boundary(V);
    else
        I = boundary(V,s);
    end
end
end