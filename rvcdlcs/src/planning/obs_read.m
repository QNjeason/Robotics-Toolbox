function [map, oq, oind] = obs_read(str,lgrid)
f1=imread(str);
bw1=imbinarize(f1);%ʹ��Ĭ��ֵ0.5
map = ~bw1(:,:,1);
[oq, oind] = map2cub(map,lgrid);
end