%Anthony Chrabieh - https://au.mathworks.com/matlabcentral/fileexchange/64978-a-star-search-algorithm
%Bonus Problem
%A* Algorithm

% arrays in this script myArray(x, y) refer to the gridded points x, y. Not
% the row, columns
% to visualise how the gridmap/array plots, you need to print
% flip(myArray', 1). The ' is because x, y are flipped to row, column and
% the flip is because (1, 1) is on the bottom left of a grid, but the top
% left when it prints (bcs its the first element in the array)

% to reverse this, use flip(flippedArray, 1)' which is the reverse
% operation

% clear all
% clc
% clf

function a_star_points = a_star(full_grid_map_visualised, starting_point, target_point)

a_star_points = [];

%Define Number of Nodes
[r, c] = size(full_grid_map_visualised);
xmax = r;
ymax = c;

%Nodes
MAP = flip(full_grid_map_visualised, 1)'; % unflip bcs its in _visualised form

%start and endpoint
start = starting_point;
goal = target_point;

%%%%%%%%%%%% Deprecated code for gridmap with start/goal baked in 
for i=1:1
% % % %To define objects, set their MAP(x,y) to inf
% MAP(MAP==-1) = inf;
% 
% %Start and Goal
% [sx, sy] = find(MAP==1);
% start = [sy, sx]
% start = [2, 3];
% 
% [gx, gy] = find(MAP==0);
% goal = [gy, gx]
% goal = [4, 4];
% % 
% % % Turn start and goal values into 0
% MAP(MAP==1) = 0
% MAP(MAP==2) = 0;

% start = [2,3];
% goal = [4, 4];
% MAP(3, 4) = inf;
% MAP(2, 3) = inf;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%To use Random Objects, uncomment this secion
% NumberOfObjects = 50;
% k = 0;
% while (k < NumberOfObjects)
%     length = max(3,randi(20));
%     x = randi(xmax-2*length)+length;
%     y = randi(ymax-2*length)+length;
%     direction = randi(4);
%     if (direction == 1)
%         x = x:x+length;
%     elseif (direction == 2)
%         x = x-length:x;
%     elseif (direction == 3)
%         y = y:y+length;
%     elseif (direction == 4)
%         y = y-length:y;
%     end
%     if (sum(isinf(MAP(x,y)))>0)
%         continue
%     end
%     MAP(x,y) = inf;
%     k = k + 1;
% end
end
%%%%%%%%%%%%%%%%%%%%%%


%Heuristic Weight%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
weight = sqrt(2); %Try 1, 1.5, 2, 2.5
%Increasing weight makes the algorithm greedier, and likely to take a
%longer path, but with less computations.
%weight = 0 gives Djikstra algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Heuristic Map of all nodes
for x = 1:size(MAP,1)
    for y = 1:size(MAP,2)
        if(MAP(x,y)~=inf)
            H(x,y) = weight*norm(goal-[x,y]);
            G(x,y) = inf;
        end
    end
end

%Plotting%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure
% ax = axes
surf(MAP')
xlim([0 xmax]);
ylim([0 ymax]);
colormap(gray);
view(2);

hold all
plot(start(1),start(2),'s','MarkerFaceColor','b')
plot(goal(1),goal(2),'s','MarkerFaceColor','m')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initial conditions%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
G(start(1),start(2)) = 0;
F(start(1),start(2)) = H(start(1),start(2));

closedNodes = [];
openNodes = [start G(start(1),start(2)) F(start(1),start(2)) 0]; %[x y G F cameFrom]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Solve
solved = false;
while(~isempty(openNodes))
    
    pause(0.001);
    
    %find node from open set with smallest F value
    [A,I] = min(openNodes(:,4));
    
    %set current node
    current = openNodes(I,:);
    plot(current(1),current(2),'o','color','g','MarkerFaceColor','g')
    
    %if goal is reached, break the loop
    if(current(1:2)==goal)
        closedNodes = [closedNodes;current];
        solved = true;
        break;
    end
    
    %remove current node from open set and add it to closed set
    openNodes(I,:) = [];
    closedNodes = [closedNodes;current];
    
    %for all neighbors of current node
    for x = current(1)-1:current(1)+1
        for y = current(2)-1:current(2)+1
            
            %if out of range skip
            if (x<1||x>xmax||y<1||y>ymax)
                continue
            end
            
            %if object skip
            if (isinf(MAP(x,y)))
                continue
            end
            
            %if current node skip
            if (x==current(1)&&y==current(2))
                continue
            end
            
            %if already in closed set skip
            skip = 0;
            for j = 1:size(closedNodes,1)
                if(x == closedNodes(j,1) && y==closedNodes(j,2))
                    skip = 1;
                    break;
                end
            end
            if(skip == 1)
                continue
            end
            
            A = [];
            %Check if already in open set
            if(~isempty(openNodes))
                for j = 1:size(openNodes,1)
                    if(x == openNodes(j,1) && y==openNodes(j,2))
                        A = j;
                        break;
                    end
                end
            end
            
            
            newG = G(current(1),current(2)) + round(norm([current(1)-x,current(2)-y]),1);
            
            %if not in open set, add to open set
            if(isempty(A))
                G(x,y) = newG;
                newF = G(x,y) + H(x,y);
                newNode = [x y G(x,y) newF size(closedNodes,1)];
                openNodes = [openNodes; newNode];
                plot(x,y,'x','color','b')
                continue
            end
            
            %if no better path, skip
            if (newG >= G(x,y))
                continue
            end
            
            G(x,y) = newG;
            newF = newG + H(x,y);
            openNodes(A,3:5) = [newG newF size(closedNodes,1)];
        end
    end
end

if (solved)
    %Path plotting
    j = size(closedNodes,1);
    path = [];
    while(j > 0)
        x = closedNodes(j,1);
        y = closedNodes(j,2);
        j = closedNodes(j,5);
        path = [x,y;path];
    end
    
    a_star_points = path;
    for j = 1:size(path,1)
        plot(path(j,1),path(j,2),'x','color','r')
        pause(0.01)
    end
else
    disp('No Path Found')
end

end