%%
clear
close all
load('sampleWell.mat')
set(0,'DefaultFigureWindowStyle','docked')
%% Polynomial Fitting
clc
clf
% Fit third order polynomial to cell count data
x = 1:length(centroidCell);
p = polyfit(x',centroidCount,3);
xp = linspace(0,length(centroidCell),1000);
fit = polyval(p,xp);
figure(1)
plot(x,centroidCount,'b','linewidth',1.5)
hold on
plot(xp,fit,'--r','linewidth',1.5)
% Find inflection point
mindip = roots(polyder(p));
mindip = round(mindip(1));
scatter(mindip,polyval(p,mindip),50,'gx','linewidth',2)
xlabel('Time')
ylabel('Number of Cells')
%% Unsupervised Clustering
% TODO:
% clean up
% Add in checks to progressively lower number of neighbors
close all
% Find initial large cluster
x = centroidCell{201};
dbidx = dbscan(x,25,10);
primaryCluster = mode(dbidx(dbidx>0),'all');
figure()
xyC = x(dbidx==primaryCluster,:);
par = CircleFitByPratt(xyC);
circlePlot(par(1),par(2),par(3)*2.5)

hold on
scatter(x(:,1),x(:,2),'rx')
scatter(xyC(:,1),xyC(:,2),'cx')

for i = 110:-1:1
    xWhole = centroidCell{i};
    % Find cell cluster in circle
    [xyC,ntry] = findCellCluster(xWhole,10,3,par);
    if isnan(xyC)
        break
    end
    figure(i)
    hold on
    scatter(xWhole(:,1),xWhole(:,2),'rx')
    scatter(xyC(:,1),xyC(:,2),'cx')
%     if mod(i,10) == 0
%         par = CircleFitByPratt(xyC);
%     end
    par = CircleFitByPratt(xyC);
    circlePlot(par(1),par(2),par(3)*2.5)
    disp(i)
end
for j = i:-10:1
    xWhole = centroidCell{j};
    figure()
    scatter(xWhole(:,1),xWhole(:,2),'rx')
end

%% Functions
function [xyC,ntry] = findCellCluster(x,minpts,ntry,par)
%findCellCluster finds clusters of cells using dbscan
% x is all of the data, neighbors is the number of minimum cells in a
% cluster, ntry is the number of times , par has data about the circle to
% be fit to the data.
epsilon = 25;
% Find coordinates in last circle
xcmat = repmat(par(1),length(x),1);
ycmat = repmat(par(2),length(x),1);
circleDists = euclid(x(:,1),xcmat,x(:,2),ycmat);
x = x(circleDists<=par(3)*2.5,:);
% Set number of neighbors
if length(x)<25 && length(x)>5
    epsilon = 15;
    minpts = 5;
elseif length(x)<=5
    minpts = 2;
    epsilon = 10;
end
% Use dbscan to find density based clusters
dbidx = dbscan(x,epsilon,minpts);
% Check if dbscan can't find any good clusters
if sum(dbidx==-1) == length(dbidx)
    xyC = NaN;
    return
end
primaryCluster = mode(dbidx(dbidx>0),'all');
xyC = x(dbidx==primaryCluster,:);
ntry = ntry+1;
end
function dist = euclid(x1,x2,y1,y2)
dist = sqrt((x1-x2).^2+(y1-y2).^2);
end