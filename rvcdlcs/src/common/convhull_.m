function I = convhull_(V)
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
                th = cart2pol(V1(:,1)-V1(1,1),V1(:,2)-V1(1,2));
                th_int = round(th(2:end)*100);
                if length(unique(th_int))==1
                    % ���ȫ������
                    I = furthest(V);
                    I = [I,I(1)];
                else
                    % �����ȫ������Ҳ��ͬһ�㣬��ȡ͹��
                    I = convhull(V);
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
