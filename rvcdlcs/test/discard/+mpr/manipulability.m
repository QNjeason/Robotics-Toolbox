function [mu,nablamu] = manipulability(th,la)
% calculate manipulability and its derivative
% - th: joint angles from 2 to M
% - la: length of arm from 1 to M
% - mu: manipulability
% - nablamu: derivative of manipulability
th = [0;th(:)];
m = size(th(:),1);
ls = zeros(m,1); %ls = sym(zeros(m,1));
lc = ls; dx = ls; dy = ls;
% lsin and lcos
for i=1:m
    for j=1:m
        ls(i) = la(i)*sin(sum(th(1:i)));
        lc(i) = la(i)*cos(sum(th(1:i)));
    end
end
% dxdth and dydth
for i=1:m
    dx(i) = 0;
    dy(i) = 0;
    for j=i:m
        dx(i) = dx(i)-ls(j);
        dy(i) = dy(i)+lc(j);
    end
end
% Jacobian
J = [dx,dy]';
% mu^2
mupow2 = det(J*J');
mu = sqrt(det(J*J'));
% second method to calcuate row vec of Hessian
Hdy = kron(ones(1,m),dy);
Hdx = kron(ones(1,m),dx);
for i=1:m-1
    for j=i:m
        Hdy(i,j) = dy(j);
        Hdx(i,j) = dx(j);
    end
end
rvecH = [-Hdy,Hdx];
% nabla mu
JJTinv = (J*J')^-1;
nablamu = mu*rvecH*kron(eye(2),J')*JJTinv(:);
nablamu(1,:) = [];
end