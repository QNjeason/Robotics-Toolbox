function hcanvas = draw_region_2d(region,obstacles,range)
import iris.thirdParty.polytopes.*
% h = figure(2);
% cla
lb = range.lb;
ub = range.ub;
hold on
n_obs = numel(obstacles);
if isempty(obstacles)
  n_obs = 0;
end
% Draw obstacle interiors
for j = 1:n_obs
  obs = obstacles{j}';
  if size(obs, 2) > 1
    if size(obs, 2) > 2
      k = convhull(obs(1,:), obs(2,:));
    else
      k = [1,2,1];
    end
    hcanvas.obstacle(j).interior = patch(obs(1,k), obs(2,k), 'k', 'FaceColor', [.6,.6,.6], 'LineWidth', 0.1);
  else
    hcanvas.obstacle(j).interior = plot(obs(1,:), obs(2,:), 'ko');
  end
end

% Draw obstacle boundaries on top
for j = 1:n_obs
  obs = obstacles{j}';
  if size(obs, 2) > 1
    if size(obs, 2) > 2
      k = convhull(obs(1,:), obs(2,:));
    else
      k = [1,2,1];
    end
    hcanvas.obstacle(j).bound = plot(obs(1,k), obs(2,k), 'k', 'LineWidth', 2);
  end
end
for i=1:length(region)
    if iscell(region)
        regionstruct = [region{:}];
    else
        regionstruct = region;
    end
    A = regionstruct(i).A;
    b = regionstruct(i).b;
%     C = regionstruct(i).C;
%     d = regionstruct(i).d;
    for j = 1:size(A,1)-4
        % a'x = b
        % set x(1) = 0
        % x(2) = b / a(2)
        ai = A(j,:);
        bi = b(j);
        if ai(2) == 0
            x0 = [bi/ai(1); 0];
        else
            x0 = [0; bi/ai(2)];
        end
        u = [0,-1;1,0] * ai';
        pts = [x0 - 1000*u, x0 + 1000*u];
        hcanvas.region(i).bound = plot(pts(1,:), pts(2,:), 'm--', 'LineWidth', 1.5);
    end
    if ~isempty(A)
        V = lcon2vert(A, b);
        k = convhull(V(:,1), V(:,2));
        hcanvas.region(i).interior = plot(V(k,1), V(k,2), 'ro-', 'LineWidth', 2);
    end
%     th = linspace(0,2*pi,100);
%     y = [cos(th);sin(th)];
%     x = bsxfun(@plus, C*y, d);
%     plot(x(1,:), x(2,:), 'b-', 'LineWidth', 2);
end
hcanvas.range = plot([lb(1),ub(1),ub(1),lb(1),lb(1)], [lb(2),lb(2),ub(2),ub(2),lb(2)], 'k-');

pad = (ub - lb) * 0.05;
xlim([lb(1)-pad(1),ub(1)+pad(1)])
ylim([lb(2)-pad(2),ub(2)+pad(2)])
axis off
% drawnow()
% pause()
