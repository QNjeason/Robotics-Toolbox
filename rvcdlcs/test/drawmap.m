clc;clear;

map=load('map2.txt');
start=[4,3]; goal=[16,18];
map_scalar=size(map,1);
%��դ���ͼ
figure
b = map;
b(end+1,end+1) = 0;
colormap([0 0 0;1 1 1]);
pcolor(0.5:size(map,2)+0.5,0.5:size(map,1)+0.5,b);%���ɫ��
set(gca,'XTick',1:size(map,2),'YTick',1:size(map,1));
axis image ij; %��ÿ��������ʹ����ͬ�����ݵ�λ������һ��
hold on;

%��ע�����յ�
scatter(start(2),start(1),'MarkerEdgeColor',[1 0 0],'MarkerFaceColor',[1 0 0], 'LineWidth',2);%start point
scatter(goal(2),goal(1),'MarkerEdgeColor',[0 1 0],'MarkerFaceColor',[0 1 0], 'LineWidth',2);%goal point
hold on;

[gx gy]=find(map==2); %�ҵ������ŵ�λ��
gate=[gx gy];
str=1:1:size(gate,1);
%�����ŵ�λ��
scatter(gate(:,2),gate(:,1),400,'y','s','filled'); %scatter(y,x,size,��ɫ,��״,���)
hold on;
%���ű����
for i=1:size(gate)
    str=num2str(i); %����ת�ַ���
    text(gate(i,2),gate(i,1),str,'FontSize',10);
    hold on;
end