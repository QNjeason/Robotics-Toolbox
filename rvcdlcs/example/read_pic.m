close all
clear

f=imread('01.png');
figure(1);
imshow(f);
title('ԭͼ');

figure(2);
bw1=imbinarize(f);%ʹ��Ĭ��ֵ0.5
imshow(bw1(:,:,1))
title('ʹ��0.5��Ϊ�ż�ʱ�Ķ�ֵͼ��');

figure(3);
level=graythresh(f);%ʹ��graythresh����Ҷ��ż�
bw2=imbinarize(f,level);
imshow(bw2(:,:,1));
title('ͨ��graythresh����Ҷ��ż�ʱ�Ķ�ֵͼ��');