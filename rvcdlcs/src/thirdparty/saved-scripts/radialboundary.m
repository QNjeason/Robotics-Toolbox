function [I,V] = radialboundary(V)
% radialboundary - Radial boundary of a set of points in 2-D or 3-D
% 
%     This MATLAB function returns a vector of point indices representing a single
%     conforming 2-D boundary around the points (x,y).
% 
%     k = radialboundary(V)
%     [k,v] = radialboundary(___)

if isempty(V)||~ismatrix(V)
    I = [];
else
    V1 = unique(V,'rows');
    if size(V1,1)==1
        % �ж��Ƿ�Ϊͬһ��
        I = 1;
        V = V(I,:);
    else
        switch size(V1,2)
            case 2
                if iscolinear(V)
                    % ���ȫ������(������ж��ڹ���������һЩ==+)
                    I = furthest(V);
                    I = [I,I(1)];
                    V = V(I,:);
                else
                    % My algorithm implementation
                    % �����ȫ������Ҳ��ͬһ�㣬ȡ����Χ����(����������ڵ�����ĵ�)
                    Vc = sum(V)/size(V,1); % ���ĵ�
                    [A,R] = cart2pol(V(:,1)-Vc(1),V(:,2)-Vc(2)); % ������
                    % �����갴R��������
                    [~,ir] = sort(R,'descend');
                    A = round(A(ir)*100);
                    % [C, ia, ic] = unique(A,'rows')
                    % ��� A ���������� C = A(ia) �� A = C(ic)�� ��� A ��
                    % ��������飬�� C = A(ia) �� A(:) = C(ic)�� ���ָ����
                    % 'rows'ѡ��� C = A(ia,:) �� A = C(ic,:)�� ��� A ��
                    % ���ʱ����� C = A(ia,:) �� A = C(ic,:)��
                    [~,ia,~] = unique(A,'rows','first');
                    I = 1:size(V,1);
                    Ir = I(ir); Ia = Ir(ia);
                    I = [Ia(:)',Ia(1)];
                    V = V(I,:);
                end
            case 3
                % �ж��Ƿ�ȫ������
                warning('3D convhull features to be updated');
                [I,V] = boundary(V);
            otherwise
                error('unknown size');
        end
    end
end