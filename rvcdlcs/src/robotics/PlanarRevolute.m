% Planar Revolute Robot 2D/3D Skeleton Model class (SE3, rpy, stdDH)
% (last mod.: 15-Jan-2021, Author: Chu Wu)
% Requires rvc & rte https://github.com/star2dust/Robotics-Toolbox
% Properties:
% - name: str (pr*)
% - type: str (elbowup* or elbowdown)
% - link: length of each link (1xm)
% - qlim: limit of each joint (2xm)
% - base: base frame (SE3)
% - tool: tool frame (SE3)
% - height: height above the amounted surface (1x1)
% - twist: twist of each joint (6xm)
% - g_sl0: initial pose of all links (1xm cell of 4x4 matrix)
% - g_st0: initial pose of tool frame (4x4)
% - radius: radius of platform (1x1)
% - altitude: height above the ground (1x1)
% Methods:
% - PlanarRevolute: construction (arg: link) 
% (opt: name, type, base, tool, height, radius ,altitude) 
% - plot (qa: 1xm, qb: 1x6 qrpy/ 1x3 q)
% (opt: workspace, dim, [no]arm, [no]plat, [no]frame, plstyle, 
%       plcolor, plthick, frcolor, frlength, frthick, frstyle, 
%       hgstyle, hgsize, hgcolor, lkcolor, lkthick, lkstyle)
% - animate (qa: 1xm, qb: 1x6 qrpy/ 1x3 q)
% Methods (Static): (for mR manipulator)
% - getTwist: calculate twists by link length and height
% - getFkine: forward kinematics
% - getIkine3: inverse kinematics for 2/3 dof manipulator
% - getJacob: Jacobian
% - getMu: get manipulablity and its derivative
classdef PlanarRevolute < handle
    properties
        % basic
        name
        type 
        % limit
        qlim
        slim
        Aq
        bq
        q0
        % arm
        link
        base
        tool
        height
        twist
        g_sl0
        g_st0
        % platform
        radius
        altitude
    end
    
    methods
        function obj = PlanarRevolute(varargin)
            % PR.PlanarRevolute  Create m-dof Planar Revolute robot object
            
            % opt statement
            opt.type = 'elbowdown';
            opt.name = 'pr';
            opt.base = SE3;
            opt.tool = SE3;
            opt.qlim = [];
            opt.slim = [];
            opt.Aq = [];
            opt.bq = [];
            opt.q0 = [];
            opt.height = 0;
            opt.radius = 0.8;
            opt.altitude = 0;
            % opt parse: only stated fields are chosen to opt, otherwise to arg
            [opt,arg] = tb_optparse(opt, varargin);
            % check validity
            if length(arg)==1
                link = arg{1}(:)';
            else
                error('unknown argument')
            end
            % type
            m = length(link);
            if size(opt.qlim,2)==0
                switch opt.type
                    case 'elbowdown'
                        qlim = [zeros(m,1),ones(m,1)*pi/2]';
                    case 'elbowup'
                        qlim = [-ones(m,1)*pi/2,zeros(m,1)]';
                    otherwise
                        qlim = [-ones(m,1)*pi/2,ones(m,1)*pi/2]';
                end
            elseif size(opt.qlim,2)==m
                qlim = opt.qlim;
            else
                error('unknown qlim');
            end
            % struct
            obj.name = opt.name;
            obj.type = opt.type;
            obj.qlim = qlim;
            obj.slim = opt.slim;
            obj.Aq = opt.Aq;
            obj.bq = opt.bq;
            obj.q0 = opt.q0;
            obj.radius = opt.radius;
            obj.altitude = opt.altitude;
            % choose properties according to type of joints
            import PlanarRevolute.*
            obj.link = link;
            obj.base = opt.base;
            obj.tool = opt.tool;
            obj.height = opt.height;
            [obj.twist, obj.g_sl0 , obj.g_st0] = getTwist(obj.link,opt.height,opt.tool);  
        end
        
        function h = plot(obj,varargin)
            % MPR.plot  Plot m-dof MobileRevolute robot object
            
            % opt statement
            opt.workspace = [-10 10 -10 10];
            opt.dim = 2;
            opt.arm = true;
            opt.plat = true;
            opt.frame = false;
            % platform opt
            opt.plcolor = 'b';
            opt.plthick = 1;
            % frame opt
            opt.frcolor = 'r';
            opt.frlength = 0.5;
            opt.frthick = 0.5;
            opt.frstyle = '-';
            % hinge opt
            opt.hgstyle = 'o';
            opt.hgsize = 2;
            opt.hgcolor = 'b';
            % link opt
            opt.lkcolor = 'b';
            opt.lkthick = 2;
            opt.lkstyle = '-';
            % opt parse: only stated fields are chosen to opt, otherwise to arg
            [opt,arg] = tb_optparse(opt, varargin);
            % argument parse
            if length(arg)==2
                % get uiaxis
                uia = [];
                % get pose
                qa = arg{1}(:)';
                % get base
                qb = arg{2}(:)';
            elseif length(arg)==3
                % get uiaxis
                uia = arg{1};
                % get pose
                qa = arg{2}(:)';
                % get base
                qb = arg{3}(:)';
            else
                error('unknown arguments');
            end
            if strcmp(get(gca,'Tag'), 'RTB.plot')
                % this axis is an RTB plot window
                rhandles = findobj('Tag', obj.name);
                if isempty(rhandles)
                    % this robot doesnt exist here, create it or add it
                    if ishold
                        % hold is on, add the robot, don't change the floor
                        h = createRobot(obj, uia, qa, qb, opt);
                        % tag one of the graphical handles with the robot name and hang
                        % the handle structure off it
                        %                 set(handle.joint(1), 'Tag', robot.name);
                        %                 set(handle.joint(1), 'UserData', handle);
                    else
                        % create the robot
                        newplot();
                        h = createRobot(obj, uia, qa, qb, opt);
                        set(gca, 'Tag', 'RTB.plot');
                    end
                end
            else
                % this axis never had a robot drawn in it before, let's use it
                h = createRobot(obj, uia, qa, qb, opt);
                set(gca, 'Tag', 'RTB.plot');
                set(gcf, 'Units', 'Normalized');
                %         pf = get(gcf, 'Position');
                %         if strcmp( get(gcf, 'WindowStyle'), 'docked') == 0
                %             set(gcf, 'Position', [0.1 1-pf(4) pf(3) pf(4)]);
                %         end
            end
            view(opt.dim); 
            if opt.dim==3
                rotate3d on;
            end
            obj.animate(qa, qb, h.group);
        end
        
        function animate(obj, qa, qb, handles)
            % MPR.animate  Animate m-dof MobileRevolute robot object
            
            if nargin < 4
                handles = findobj('Tag', obj.name);
            end
            % animate
            qb = SE3.qrpy(qb).toqrpy;
            fk = obj.fkine(qa,qb); p_hg = fk.tv;
            for i=1:length(handles.Children) % draw frame first otherwise there will be delay
                if strcmp(get(handles.Children(i),'Tag'), [obj.name '-plat-floor'])
                    p_fv0 = handles.Children(i).UserData{1};
                    p_siz = handles.Children(i).UserData{2};
                    p_fv = h2e(SE3.qrpy(qb).T*e2h(p_fv0'));
                    x_fv = reshape(p_fv(1,:),p_siz);
                    y_fv = reshape(p_fv(2,:),p_siz);
                    z_fv = reshape(p_fv(3,:),p_siz);
                    set(handles.Children(i), 'XData', x_fv,'YData', y_fv,'ZData', z_fv);
                end
                if strcmp(get(handles.Children(i),'Tag'), [obj.name '-plat-wall'])
                    p_fv0 = handles.Children(i).UserData;
                    p_fv = h2e(SE3.qrpy(qb).T*e2h(p_fv0'));
                    set(handles.Children(i), 'Vertices', p_fv');
                end
                if strcmp(get(handles.Children(i),'Tag'), [obj.name '-link'])
                    set(handles.Children(i), 'XData', p_hg(1,:),'YData', p_hg(2,:),'ZData', p_hg(3,:));
                end
                if strcmp(get(handles.Children(i),'Tag'), [obj.name '-tool'])
                    set(handles.Children(i),'matrix',fk(end).T);
                end
                if strcmp(get(handles.Children(i),'Tag'), [obj.name '-base'])
                    set(handles.Children(i),'matrix',fk(i).T);
                end
            end
        end
        
        function fk = fkine(obj,qa,qb)
            % PR.fkine Forward kinematics for m-dof planar revolute manipulator
            % - qa: joint posture (1xm)
            % - qb: base frame pose (1x6 qrpy/ 1x3 q)
            % - fk: poses of all joints and tool frame (1xm SE3) 
            % use fk(end).t to get the coordinate of tool point
            import PlanarRevolute.*
            for i=1:length(obj)
                for j=1:length(qa(i,:))
                    g_sl{j} = transl([0,0,obj(i).height])*obj(i).g_sl0{j};
                    for k=j:-1:1
                        g_sl{j} =  expm(wedge(obj(i).twist(:,k)).*qa(i,k))*g_sl{j};
                    end
                end

                g_st = obj(i).g_st0;
                for k=length(qa(i,:)):-1:1
                    g_st =  expm(wedge(obj(i).twist(:,k)).*qa(i,k))*g_st;
                end
                               
                g_ss = {eye(4),transl([0,0,obj(i).height])}; 
                g_hg = [g_ss,g_sl,{g_st}];
                for j = 1:length(g_hg)
                    fk(i,j) = SE3.qrpy(qb(i,:))*SE3([0,0,obj(i).altitude])*obj(i).base*SE3(g_hg{j});
                end
            end
        end
        
        function qa = ikine2d(obj,pe,qb)
            import PlanarRevolute.*
            for i=1:length(obj)
                pbe(i,:) = (SE2(qb).inv*pe(i,:)')';
                negmup2 = @(th) -getMu(obj(i).link,th);
                qa(i,:) = fmincon(negmup2,obj(i).q0',obj(i).Aq,obj(i).bq,[],[],...
                    obj(i).qlim(1,:),obj(i).qlim(2,:),@(th) ...
                    fkcon(obj(i).link,th,pbe(i,:)));
            end
        end
        
        function qb = bkine(obj,qa,gfk)
            % PR.fkine Forward kinematics for m-dof planar revolute manipulator
            % - qa: joint posture (1xm)
            % - qb: base frame pose (1x6 qrpy/ 1x3 q)
            % - gfk: poses of tool frame (1xm SE3) 
            import PlanarRevolute.*
            if ~isa(gfk,'SE3')
                gfk = SE3.qrpy(gfk);
            end
            for i=1:length(obj)
                for j=1:length(qa(i,:))
                    g_sl{j} = transl([0,0,obj(i).height])*obj(i).g_sl0{j};
                    for k=j:-1:1
                        g_sl{j} =  expm(wedge(obj(i).twist(:,k)).*qa(i,k))*g_sl{j};
                    end
                end

                g_st = obj(i).g_st0;
                for k=length(qa(i,:)):-1:1
                    g_st =  expm(wedge(obj(i).twist(:,k)).*qa(i,k))*g_st;
                end
                
                gb(i) = gfk(i)*SE3(g_st).inv*obj(i).base.inv*SE3([0,0,obj(i).altitude]).inv;
            end
            qb3d = gb.toqrpy;
            qb = qb3d(:,[1,2,6]);
        end
        
        function l = lk(obj)
            
            l = [];
            for i=1:length(obj)
                l = [l;obj(i).link];
            end
        end
    end
    
    methods (Access = protected)
        function h = createRobot(obj, uia, qa, qb, opt)
            % create an axis
            ish = ishold();
            if ~ishold
                % if hold is off, set the axis dimensions
                if ~isempty(opt.workspace)
                    axis(opt.workspace);
                end
                hold on
            end
            
            if isempty(uia)
                group = hggroup('Tag', obj.name);
            else
                group = hggroup('Tag', obj.name, 'Parent', uia);
            end
            h.group = group;
            
            qb = SE3.qrpy(qb).toqrpy;
            fk = fkine(obj,qa,qb);
            p_hg = fk.tv;
            
            if opt.plat
                [X,Y,Z] = cylinder(obj.radius,12);          
                Z = Z*obj.altitude; 
                [TRI,V] = surf2patch(X,Y,Z);
                h.floor = patch('xdata',X','ydata',Y','zdata',Z','FaceColor', 'y',...
                    'EdgeColor', opt.plcolor, 'LineWidth', opt.plthick, 'parent', group );
                h.wall = patch('vertices',V,'faces',TRI,'FaceColor', 'y',...
                    'EdgeColor', opt.plcolor, 'LineWidth', 0.1, 'parent', group);
                h.floor.UserData = {[vec(X'),vec(Y'),vec(Z')],size(X')};
                h.wall.UserData = V;
                set(h.floor,'Tag', [obj.name '-plat-floor']);
                set(h.wall,'Tag', [obj.name '-plat-wall']);
            end
            
            if opt.arm
                h.link = line(p_hg(1,:),p_hg(2,:),p_hg(3,:),'Color',opt.lkcolor,'LineStyle', opt.lkstyle, 'LineWidth', opt.lkthick, 'MarkerFaceColor', opt.hgcolor, 'Marker', opt.hgstyle, 'MarkerSize', opt.hgsize, 'parent', group);
                set(h.link,'Tag', [obj.name '-link']);
            end
            
            if opt.frame
                if opt.arm
                    ftool = fk(end);
                    h.ftool = ftool.plot('color', opt.frcolor,'length',opt.frlength, 'thick', opt.frthick, 'style', opt.frstyle);
                    set(h.ftool,'parent',group);
                    set(h.ftool,'Tag', [obj.name '-tool']);
                end
                if opt.plat
                    fbase = fk(1);
                    h.fbase = fbase.plot('color', opt.frcolor,'length',opt.frlength, 'thick', opt.frthick, 'style', opt.frstyle);
                    set(h.fbase,'parent',group);
                    set(h.fbase,'Tag', [obj.name '-base']);
                end
            end
            
            % restore hold setting
            if ~ish
                hold off
            end
        end
        
%         function updateProps(obj,opt)
%             import PlanarRevolute.*
%             obj.base = opt.base;
%             obj.tool = opt.tool;
%             obj.height = opt.height;
%             [obj.twist, obj.g_sl0 , obj.g_st0] = getTwist(obj.link,opt.height,opt.tool);
%         end
    end
    
    methods (Static)
        function [xi, g_sl0, g_st0] = getTwist(link,height,tool)
            % MPR.getTwist  Calculate POE twist (6 x m+1) by link for mR manipulator
            % - link: link lengths (1xm)
            % - height: height above the surface of base (1x1)
            % - tool: transformation from the last joint to tool frame
            
            % mounted place (translation only for mR)
            % indeed hb_T can be chosen as any transformation
            % mounted place (translation only)
            height_T = transl([0,0,height]);
            l0 = [0;link(:)];
            for i=1:length(l0)
                p_hg0(:,i) = [sum(l0(1:i)),0,0]';
            end
            for i=1:length(link)
                g_sl0{i} = transl([sum(link(1:i)),0,0]);
            end
            % rotation axis
            w = [0,0,1]';
            % joint twists
            for i=1:length(l0)-1
                xi(:,i) = [-skew(w)*p_hg0(:,i);w];
            end
            % tool twist
            g_st0 = height_T*transl(p_hg0(:,end))*tool.T;
            xi(:,i+1) = vee(logm(g_st0));
        end
        
        
        function pfk = getFkine(link,th)
            % PR.getFkine  Forward kinematics coordinate for m-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            % - pfk: position of end-effector (1x2)
            
            pfk = zeros(size(link,1),2);
            for j=1:size(link,1)
                if isvec(th)
                    m = length(th);
                    th = th(:)';
                else
                    m = size(th,2);
                end
                % lsin and lcos
                pfkj = [0;0];
                for i=1:m
                    ls = link(j,i)*sin(sum(th(j,1:i)));
                    lc = link(j,i)*cos(sum(th(j,1:i)));
                    pfkj = pfkj+[lc;ls];
                end
                pfk(j,:) = pfkj;
            end
        end
        
        function pfk = getHinge(link,th,ind,str)
            % PR.getHinge  Hinge coordinate for m-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            % - pfk: position of end-effector (1x2)
            
            pfk = zeros(size(link,1),2);
            for j=1:size(link,1)
                if isvec(th)
                    m = length(th);
                    th = th(:)';
                else
                    m = size(th,2);
                end
                % select type
                if str=='e'
                    list = ind:m;
                elseif str=='b'
                    list = 1:ind;
                else
                    error("input should be 'e' or 'b'.")
                end
                % lsin and lcos
                pfkj = [0;0];
                for i=list
                    ls = link(j,i)*sin(sum(th(j,1:i)));
                    lc = link(j,i)*cos(sum(th(j,1:i)));
                    pfkj = pfkj+[lc;ls];
                end
                pfk(j,:) = pfkj';
            end
        end
        
        function J = getNablaHinge(link,th,ind,str)
            % PR.getNablaHinge  Nabla hinge for m-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            
            m = length(th);
            ls = zeros(m,1);
            lc = ls; dx = ls; dy = ls;
            % lsin and lcos
            for i=1:m
                ls(i) = link(i)*sin(sum(th(1:i)));
                lc(i) = link(i)*cos(sum(th(1:i)));
            end
            % dxdth and dydth
            for i=1:m % derivative of which joint
                dx(i) = 0;
                dy(i) = 0;
                % select type
                if str=='e'
                    list = max(ind,i):m;
                elseif str=='b'
                    list = i:ind;
                else
                    error("input 4 should be 'e' or 'b'.")
                end
                for j=list % how many cos or sin should be added
                    dx(i) = dx(i)-ls(j);
                    dy(i) = dy(i)+lc(j);
                end
            end
            % Jacobian
            J = [dx,dy]';
        end
        
        function th = getIkine3(link,qfk,type)
            % PR.prIkine  Inverse kinematics for 2 or 3-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - qfk: pose of forward kinematics (1x3) (SE2 configuration [x,y,phi])
            % - type: elbow type ('elbowup' or 'elbowdown')
            
            if length(link)==3
                l1 = link(1); l2 = link(2); l3 = link(3);
                end_SE3 = SE2(qfk)*SE2([-l3,0]);
            elseif length(link)==2
                l1 = link(1); l2 = link(2);
                end_SE3 = SE2(qfk);
            else
                error('link length exceeds the degree of freedom (max 3)');
            end
            gT = end_SE3.q;
            x = gT(1); y = gT(2); thT = gT(3);
            % angle => inverse kinematics of three-link planar robot
            if nargin<3
                type = 'elbowdown';
            end
            switch type
                case 'elbowup' % up-elbow
                    ue = -1;
                case 'elbowdown' % down-elbow
                    ue = 1;
                otherwise
                    error('invalid elbow type');
            end
            c2 = (x^2+y^2-l1^2-l2^2)/(2*l1*l2);
            th2 = acos(c2)*ue;
            s2 = sqrt(1-c2^2);
            th1 = atan2(y,x)-atan2(l2*s2,l1+l2*c2)*ue;
            if length(link)==3
                th3 = thT-th1-th2;
                th = [th1,th2,th3];
            else
                th = [th1,th2];
            end
        end
        
        function [mu,dmu] = getMu(link,th)
            % PR.getMu   Calculate manipulability and its derivative
            % - th: joint angles (1xm)
            % - mu: manipulability (1x1)
            % - dmu: derivative of manipulability(1xm)

            import PlanarRevolute.*
            m = length(link);
            % Jacobian
            J = getJacob(link,th);
            dx = J(1,:)'; dy = J(2,:)';
            % mu^2
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
            dmu = mu*rvecH*kron(eye(2),J')*JJTinv(:);
        end
        
        function J = getJacob(link,th)
            % PR.getJacob  Jacobian for m-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            
            m = length(th);
            ls = zeros(m,1);
            lc = ls; dx = ls; dy = ls;
            % lsin and lcos
            for i=1:m
                ls(i) = link(i)*sin(sum(th(1:i)));
                lc(i) = link(i)*cos(sum(th(1:i)));
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
        end
        
        function J = getJacobDot(link,th,dth)
            % PR.getJacobDot  Jacobian dot for m-dof planar revolute manipulator
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            % - dth: joint rates (1xm)
            
            m = length(th);
            ls = zeros(m,1);
            lc = ls; dx = ls; dy = ls;
            % lsin and lcos
            for i=1:m
                ls(i) = link(i)*sin(sum(th(1:i)))*dth(i);
                lc(i) = link(i)*cos(sum(th(1:i)))*dth(i);
            end
            % dxdth and dydth
            for i=1:m
                dx(i) = 0;
                dy(i) = 0;
                for j=i:m
                    dx(i) = dx(i)-lc(j);
                    dy(i) = dy(i)-ls(j);
                end
            end
            % Jacobian
            J = [dx,dy]';
        end
        
        function [c,ceq] = fkcon(link,th,pfk)
            % PR.fkcon  Get the forward kinematic equation constraints
            % - link: link lengths (1xm)
            % - th: joint angles (1xm)
            % - pfk: desired position of end-effector (1x2)
            import PlanarRevolute.*
            ceq = getFkine(link,th)-pfk(:)';
            c = [];
        end
        
        function robout = copy(robin,num,name)
            for i=1:num
                if num>1
                   rob_name = [name '_' num2str(i)];
                else
                    rob_name = name;
                end
                robout(i) = PlanarRevolute(robin.link,'name',...
                    rob_name,'height',robin.height,'radius',...
                    robin.radius,'altitude',robin.altitude,'qlim',...
                    robin.qlim,'Aq',robin.Aq,'bq',robin.bq,'q0',robin.q0);
            end
        end
    end
end