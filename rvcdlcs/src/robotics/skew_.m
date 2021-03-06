function vs = skew_(v)
%  skew_ Create skew-symmetric matrix
%
%   S = skew(V) is a skew-symmetric matrix formed from V.
%
%   If V (1x1) then S =
%
%             | 0  -v |
%             | v   0 |
%
%   if V (1x2) then S =
%             | -vy vx|
%
%   and if V (1x3) then S =
%
%             |  0  -vz   vy |
%             | vz    0  -vx |
%             |-vy   vx    0 |
%
%
%   Notes::
%   - This is the inverse of the function VEX().
%   - These are the generator matrices for the Lie algebras so(2) and so(3).
%
%   References::
%   - Robotics, Vision & Control: Second Edition, Chap 2,
%     P. Corke, Springer 2016.
if isvec(v,1)||isvec(v,2)||isvec(v,3)
    v = v(:)';
else
    error('unknown size');
end
vs = [];
if isvec(v,2)
    S = skew([v,0]);
    vs = [vs;S(3,1:2)];
else
    vs = [vs;skew(v)];
end
end