% Cooperative Manipulation 3D Model class (rpy, stdDH)
% (last mod.: 06-01-2020, Author: Chu Wu)
% Requires rvc & rte https://github.com/star2dust/Robotics-Toolbox
% Properties:
% - name: str (cm*)
% - robot: MobilePlanarRevolute
% - payload: Cylinder
% - height: payload height above the ground
% Methods:
% - CooperativeManipulation: construction (opt: name) (arg: edge, link, mh, radius)
% - plot (opt: workspace, [no]frame, framecolor)
% - animate
classdef CooperativeManipulation < handle
    properties
        name
        robot
        payload
        height
        g_c2e_bar % initial/desired g_c2e
        p_e2m_bar % initial/desired p_e2m
    end
    
    methods
        function obj = CooperativeManipulation(varargin)
            % CM.CooperativeManipulation   Creates planar CooperativeManipulation object
            % opt statement
            opt.name = 'cm';
            % opt parse: only stated fields are chosen to opt, otherwise to arg
            [opt,arg] = tb_optparse(opt, varargin);
            % check validity
            if length(arg)==3
                nrob = arg{1};
                nlink = arg{2};
                radius = arg{3};
            else
                error('unknown argument')
            end
            link = ones(nlink,1)*0.8*radius; edge = [1,.8,.5]*radius; mh = [0,0,1]*radius;
            % construct robot
            obj.robot = MobilePlanarRevolute(edge,link,mh,'name','rob1','type','elbowup');
            for i=2:nrob
                obj.robot(i) = MobilePlanarRevolute(edge,link,mh,'name',['rob' num2str(i)],'type','elbowup');
            end
            obj.payload = Cylinder(radius,0.2,'name','payload');
            obj.name = opt.name;
            obj.height = edge(3)+mh(3);
            obj.initialization;
        end
        
        function h = plot(obj,varargin)
            % CM.plot  Plot planar CooperativeManipulation object
            for i=1:length(obj.robot)
                edge(i,:) = obj.robot(i).base.edge;
            end
            % opt statement
            opt.workspace = [];
            opt.frame = false;
            opt.framecolor = 'br';
            opt.framelength = [sum(sum(edge))/size(edge,1)/size(edge,2)/3,obj.payload.radius/3];
            opt.framethick = [1 1];
            opt.framestyle = '-';
            % opt parse: only stated fields are chosen to opt, otherwise to arg
            [opt,arg] = tb_optparse(opt, varargin);
            % argument parse
            if length(arg)==3
                % get config
                g_r2c = arg{1};
                psi = arg{2};
                th_tilde = arg{3};
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
                        h = createCM(obj,g_r2c,psi,th_tilde,opt);
                        % tag one of the graphical handles with the robot name and hang
                        % the handle structure off it
                        %                 set(handle.joint(1), 'Tag', robot.name);
                        %                 set(handle.joint(1), 'UserData', handle);
                    else
                        % create the robot
                        newplot();
                        h = createCM(obj,g_r2c,psi,th_tilde,opt);
                        set(gca, 'Tag', 'RTB.plot');
                    end
                end
            else
                % this axis never had a robot drawn in it before, let's use it
                h = createCM(obj,g_r2c,psi,th_tilde,opt);
                set(gca, 'Tag', 'RTB.plot');
                set(gcf, 'Units', 'Normalized');
                pf = get(gcf, 'Position');
                %         if strcmp( get(gcf, 'WindowStyle'), 'docked') == 0
                %             set(gcf, 'Position', [0.1 1-pf(4) pf(3) pf(4)]);
                %         end
            end
            view(3); grid on;
            obj.animate(g_r2c,psi,th_tilde);
        end
        
        function animate(obj,g_r2c,psi,th_tilde)
            % CM.animate  Animate planar CooperativeManipulation object
            if nargin < 4
                handles = findobj('Tag', obj.name);
            end
            [qc,qr] = obj.min2config(g_r2c,psi,th_tilde);
            % animate
            obj.payload.animate(qc);
            for i=1:length(obj.robot)
                obj.robot(i).animate(qr(i,:));
            end   
        end
        
        function obj = initialization(obj)
            % CM.initialization  Initialize CM.g_c2e_bar (1xn SE2) and CM.p_e2m_bar (2xn)
            % - g_c2e is uniformly distributed around the payload 
            % - p_e2m is determined by maximum manipulability index
            n = length(obj.robot);
            for i=1:n    
                % g_c2e_bar
                phi_c2e_bar(i) = -(n-1)*pi/n+2*pi/n*(i-1);
                p_c2e_bar(:,i) = obj.payload.radius*[-cos(phi_c2e_bar(i)),-sin(phi_c2e_bar(i))];
                g_c2e(i) = SE2(p_c2e_bar(:,i),phi_c2e_bar(i));
                % p_e2m_bar
                [~,th_e_bar(i,:)] = obj.robot(i).manipulability;
                p_e2m(:,i) = -obj.robot(i).mrfkine(obj.robot(i).link,th_e_bar(i,:));
            end
            obj.g_c2e_bar = g_c2e;
            obj.p_e2m_bar = p_e2m;
        end
        
        function g_r2e = graspPose(obj,g_r2c,psi)
            % CM.graspPose  Return real end-effector pose g_r2e (1xn SE2)
            n = length(obj.robot);
            for i=1:n  
                % g_r2e
                p_r2e(:,i) = h2e(g_r2c.T*e2h(obj.g_c2e_bar(i).t));
                phi_r2e(i) = g_r2c.angle+obj.g_c2e_bar(i).angle+psi;
                g_r2e(i) = SE2(p_r2e(:,i),phi_r2e(i));
            end
        end
        
        function p_r2m = baseTransl(obj,g_r2c,psi,th_tilde)
            % CM.baseTransl  Return real mobile base translation p_r2m (2xn)
            % - p_r2m is obtained by g_r2c, psi and th_tilde
            n = length(obj.robot);
            % g_r2e
            g_r2e = obj.graspPose(g_r2c,psi);
            for i=1:n  
                % p_e2m
                delta = [-ones(1,m-1);eye(m-1)];
                th_e(i,:) = th_tilde(i,:)*delta';
                p_e2m(:,i) = -obj.robot(i).mrfkine(obj.robot(i).link,th_e(i,:));
                % p_r2m
                p_r2m(:,i) = h2e(g_r2e(i).T*e2h(p_e2m(:,i)));
            end
        end
        
        function p_r2m_hat = formationTransl(obj,g_r2c,scale)
            % CM.formationTransl  Return esitimated mobile base translation p_r2m_hat (2xn)
            % - p_r2m_hat is the base translation in the desired formation
            n = length(obj.robot);
            for i=1:n    
                % initial q_r2c and psi are zeros
                % p_r2cm_hat = p_c2m_bar = g_c2e_bar*p_e2m_bar
                p_r2cm_bar(:,i) = h2e(obj.g_c2e_bar(i).T*e2h(obj.p_e2m_bar(:,i))); 
                p_r2m_hat(:,i) = g_r2c.t+scale*p_r2cm_bar(:,i);
            end
        end
        
        function th_r = formationIkine(obj,g_r2c,psi,scale)
            % CM.formationIkine  Inverse kinematics of robots in formation 
            % return th_r (nxm) relative to r frame
            n = length(obj.robot);
            % g_r2e
            g_r2e = obj.graspPose(g_r2c,psi);
            % p_r2cm_hat = p_c2m_bar = g_c2e_bar*p_e2m_bar
            p_r2m_hat = formationTransl(obj,g_r2c,scale);
            for i=1:n    
                % th_r
                base_r2m = SE3.qrpy([p_r2m_hat(:,i)',obj.robot(i).base.edge(3)/2,0,0,0]);
                tool_r2e = SE3.qrpy([g_r2e(i).t',obj.height,0,0,g_r2e(i).angle]);
                q_r(i,:) = obj.robot(i).ikine(tool_r2e,base_r2m);
                th_r(i,:) = q_r(i,4:end);
            end
        end
    end
    
    methods (Access = protected)
        function h = createCM(obj,g_r2c,psi,th_tilde,opt)
            % CM.createCM  Create handles for planar CooperativeManipulation object plot
            
            % create an axis
            ish = ishold();
            if ~ishold
                % if hold is off, set the axis dimensions
                if ~isempty(opt.workspace)
                    axis(opt.workspace);
                end
                hold on
            end
            
            [qc,qr] = obj.min2config(g_r2c,psi,th_tilde);
            
            group = hggroup('Tag', obj.name);
            h.group = group;
            if opt.frame
                h.payload = obj.payload.plot(qc,'facecolor','g','frame','framecolor', opt.framecolor(2),'framelength', opt.framelength(2), 'framethick', opt.framethick(2));
                for i=1:length(obj.robot)
                    h.robot(i) = obj.robot(i).plot(qr(i,:),'frame','framecolor', opt.framecolor(1),'framelength',opt.framelength(1), 'framethick', opt.framethick(1), 'framestyle', opt.framestyle);
                end
            else
                h.payload = obj.payload.plot(qc,'facecolor','g');
                for i=1:length(obj.robot)
                    h.robot(i) = obj.robot(i).plot(qr(i,:));
                end
            end
            set(h.robot(i).group,'parent',group);
            set(h.payload.group,'parent',group);
            
            % restore hold setting
            if ~ish
                hold off
            end
        end
        
        function [payload_config,robot_config] = min2config(obj,g_r2c,psi,th_tilde)
            % CM.min2config  Return payload_config (1x6) and rob_config (1x(3+m))  
            payload_config = [g_r2c.t',obj.height,0,0,g_r2c.angle];
            % g_r2e
            g_r2e = obj.graspPose(g_r2c,psi);
            for i=1:length(obj.robot)
                % phi_r2e
                phi_r2e(i) = g_r2e(i).angle;
                th(i,:) = [phi_r2e(i)-sum(th_tilde(i,:)),th_tilde(i,:)]; % m-dof arm
                p_r2em(:,i) = -obj.robot(i).mrfkine(obj.robot(i).link,th(i,:));
                % p_r2e
                p_r2e(:,i) = g_r2e(i).t;
                robot_config(i,:) = [p_r2e(:,i)'+p_r2em(:,i)',0,th(i,:)];
            end
        end
    end
end