close all
clear

% frames
% - r: reference
% - c: centroid
% - m: mobile base
% symbols
% - g: SE2/SE3
% - p: translation (2x1)
% - phi: rotation (1x1)
% - q = [p',phi]: translation and rotation (1x3)
% relations 
% - g_r: g_r relative to inertia frame
% - g_r2c: g_c relative to r frame
% - g_r2em: g_em relative to r frame

nrob = 4; nlink = 3; radius = .5;
cm = DistributedManipulation(nrob,nlink,radius,'name','cm');

g_r = SE2(kron(ones(nrob,1),[2.5,2.5,0])); psi = 0; scale = 1;
g_tilde = SE2(rot2(psi));
th_r = cm.formationIkine(g_tilde,scale);
p_r2m_hat = cm.formationTransl(scale);
for i=1:nrob
   p_m_hat(:,i) = h2e(g_r(i).T*e2h(p_r2m_hat(:,i)));    
end

% for i=1:nrob
%    p_e2c_bar(:,i) = -cm.g_c2e_bar(i).R'*cm.g_c2e_bar(i).t;    
% end



figure
cm.plot(g_r,g_tilde,th_r(:,2:end),'workspace',[0 10 0 10 0 10]/2,'frame'); hold on
h = plot(p_m_hat(1,[1:end,1]),p_m_hat(2,[1:end,1]));
view(-30,70)





% write video
video_on = false;
if video_on
    respath = '/home/chu/Documents/MATLAB/Results/';
    videoname = [respath 'cooperative_manipulation_demo_v1.1'];
    writerObj = VideoWriter(videoname);
    open(writerObj);
end
for t=0:0.05:3
    if t<=1
        psi = pi/4*t; scale = 1-0.3*t;
    elseif t>1&&t<=2
        psi = pi/4-pi/4*(t-1); scale = 1-0.3+0.6*(t-1);
    else
        psi = 0; scale = 1+0.3-0.3*(t-2);
    end
%     if t<=1.5
%         g_r = SE2(kron(ones(nrob,1),[2.5,2.5,0]+ones(1,3)/2*t));
%     else
%         g_r = SE2(kron(ones(nrob,1),[2.5,2.5,0]+ones(1,3)/2*(3-t)));
%     end
    g_tilde = SE2(rot2(psi));
    th_r = cm.formationIkine(g_tilde,scale);
    p_r2m_hat = cm.formationTransl(scale);
    for i=1:nrob
        p_m_hat(:,i) = h2e(g_r(i).T*e2h(p_r2m_hat(:,i)));
    end
    cm.animate(g_r,g_tilde,th_r(:,2:end));
    set(h,'xdata',p_m_hat(1,[1:end,1]),'ydata',p_m_hat(2,[1:end,1]));
    if video_on
        frame = getframe;
        frame.cdata = imresize(frame.cdata,[480,640]);
        writeVideo(writerObj,frame);
    end
end
if video_on
    close(writerObj);
end

% q0 = [0,0,0,0,0,0];
% q1 = [1,0,0,-1,1,2];
% q2 = [1,1,0,1,2,1];
% [qq,~,~,tq] = calctraj([q0;q1;q2],0.1*ones(size(q0)),0.1,1);
% tic;
% playspeed = 2;
% while toc<tq(end)/playspeed
%     tnow = toc*playspeed;
%     % choose via point in time 'tnow'
%     q = interp1(tq,qq,tnow); 
%     % update object
%     cm.animate(q);
%     drawnow
% end