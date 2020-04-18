function c = bracket(a,b)
% calculate Lie bracket of twists a and b
ch = wedge(a)*wedge(b)-wedge(b)*wedge(a);
c = vee(ch);
end