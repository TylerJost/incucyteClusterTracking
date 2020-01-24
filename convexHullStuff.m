% One way to better quantify the data might be to look at the outer
% perimeter - the convex hull and see how

clc
clear
load('convexHullQL.mat')
%%
clf
tic
gscatter(x(:,1),x(:,2),dbidx)

x2 = x(dbidx==12,:);
ptsx2T = dilateHull(x2,1.1);

hold on
plot(ptsx2T(:,1),ptsx2T(:,2),'m')

in = inpolygon(x(:,1),x(:,2),ptsx2T(:,1),ptsx2T(:,2));
scatter(x(in,1),x(in,2),'.k')
inpolyP = x(in,:);

idx = dbscan(inpolyP,15,4);
hold on
% gscatter(inpolyP(:,1),inpolyP(:,2),idx)

[C,ia,ic] = unique(idx);
counts = accumarray(ic,1);
clusterSizes = sortrows([C, counts],2,'descend');
toc
%%
cluster1Poly = polyCell(:,1);
clusterSizes = zeros(length(cluster1Poly),1);
for i = 1:length(cluster1Poly)
   clusterSizes(i) = polyarea(cluster1Poly{i}(:,1),cluster1Poly{i}(:,2)); 
end
%%
clf
minArea = 18500;

pts = clusterCell{70,1};
scatter(centroidCell{70}(:,1),centroidCell{70}(:,2),'.r')
hold on
scatter(pts(:,1),pts(:,2),'.k')
plot(polyCell{70,1}(:,1),polyCell{70,1}(:,2),'--b','LineWidth',1.5)

hullAreaC = polyarea(polyCell{70,1}(:,1),polyCell{70,1}(:,2));
if hullAreaC<minArea
    sizeFactor = minArea/hullAreaC;
    [hullMin, areaHull] = dilateHull(polyCell{70,1},sizeFactor);
end
plot(hullMin(:,1),hullMin(:,2),'--g','LineWidth',1.5)

