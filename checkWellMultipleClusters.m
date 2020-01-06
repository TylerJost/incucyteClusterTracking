%%
clear
close all
load('WellE6.mat')
set(0,'DefaultFigureWindowStyle','docked')
%% Polynomial Fitting
clc
% Fit third order polynomial to cell count data
x = 1:length(centroidCell);
p = polyfit(x',centroidCount,3);
xp = linspace(0,length(centroidCell),1000);
fit = polyval(p,xp);
mindip = roots(polyder(p));
mindip = round(mindip(1));
analysisStart = floor((length(x)-mindip)/2)+mindip;
figure(1)
plot(x,centroidCount,'b','linewidth',1.5)
hold on
plot(xp,fit,'--r','linewidth',1.5)
% Find inflection point
scatter(mindip,polyval(p,mindip),50,'gx','linewidth',2)
xlabel('Time')
ylabel('Number of Cells')
%% Perform Initial Check
figure()
% Initial values to alter
analysisStart = 138;
cellThresh = 100;
epsilon = 20;
minpts = 5;

x = centroidCell{analysisStart};
dbidx = dbscan(x,epsilon,minpts);
% Use cellThresh to get rid of small cell clusters
clusters = unique(dbidx(dbidx>0));
clusterSizes = zeros(length(clusters),1);
% Store cluster sizes
for im = 1:length(clusters)
    clusterSizes(im) = sum(dbidx==clusters(im));
end
% Get rid of small clusters
clusterI = find(clusterSizes>cellThresh);
for im = 1:length(dbidx)
    if isempty(find(dbidx(im) == clusterI,1))
       dbidx(im) = -1;         
    end
end
clf
titleInfo = sprintf('Cell Thresh = %g\nepsilon = %g\nminpts=%g',...
    cellThresh,epsilon,minpts);
gscatter(x(:,1),x(:,2),dbidx)
title(titleInfo)
%% Unsupervised Clustering
close all
[allPar,clusterCell,tr] = trackClusters(dates,centroidCell,analysisStart,cellThresh,epsilon,minpts);
%% Quick Plotting
imRange = analysisStart-1:-1:1;
% imRange = 35:-1:1;
quickPlotWell(dates,imRange,clusterCell,centroidCell,allPar)
%% Export Gif
imRangePlot = analysisStart-1:-1:1;
fileName = 'WellE6';
makeWellGif(imRangePlot,fileName,allPar,clusterCell,dates,centroidCell)