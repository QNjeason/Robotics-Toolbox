function [C, d, volume] = maximal_ellipse(A,b)

% poly = iris.Polyhedron(A, b).reduce();
[Ad, ia] = unique(A,'rows');
A = Ad;
b = b(ia);

% if you have mosek, you can use mosek_nofusion(2x)/mosek_ellipsoid(1x)
% [C, d] = iris.inner_ellipsoid.mosek_nofusion(A, b);
% [C, d] = iris.inner_ellipsoid.mosek_ellipsoid(A, b);

% If Mosek fails for you, you can use CVX with the free SDPT3 solver,
% but it will be much (about 100X) slower. Just swap the above line for the
% following:
A(isnan(A)) = 0;
A(isinf(A)) = 10^5;
b(isnan(b)) = 0;
b(isinf(b)) = 10^5;
[C, d] = iris.inner_ellipsoid.cvx_ellipsoid(A, b);

volume = det(C);

