function I = closure(V)
% generate the closure of vertices

if isempty(V)||~ismatrix(V)
    I = [];
else
    V1 = unique(V,'rows');
    if size(V1,1)==1
        % �ж��Ƿ�Ϊͬһ��
        I = 1;
    else
        switch size(V1,2)
            case 2
                % �ж��Ƿ�ȫ������
                A = cart2pol(V1(:,1)-V1(1,1),V1(:,2)-V1(1,2));
                th_int = ceil(A(2:end)*100);
                if length(unique(th_int))==1
                    % ���ȫ������
                    I = furthest(V);
                    I = [I,I(1)];
                else
                    % �����ȫ������Ҳ��ͬһ�㣬��ȡ����Χ����
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
                end
            case 3
                % �ж��Ƿ�ȫ������
                warning('3D convhull features to be updated');
                I = convhull(V);
            otherwise
                error('unknown size');
        end
    end
end