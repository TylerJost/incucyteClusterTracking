%% Load Data
clear
clc
close all
% fileName = 'GH1818_F7.mat'; % Poor cluster splitting
fileName = 'GH1818_E3.mat'; % Non-dense well
% fileName = 'GH1818_E6.mat'; % Ideal-case well
% fileName = 'GH1818_B3.mat'; % Cutting off too early
load(fileName)
set(0,'DefaultFigureWindowStyle','docked')
%% Polynomial Fitting
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
% scatter(mindip,polyval(p,mindip),50,'gx','linewidth',2)
xlabel('Time')
ylabel('Number of Cells')
%% Calibration
figure()
% Initial values to alter
% Minimum number of cells for a cluster to start with
% epsilon is the radius which checks for other core points
% minpts is the minimum number of points that can be reached using epsilon
%
% For more explanation on DBSCAN see: 
% https://en.wikipedia.org/wiki/DBSCAN#Preliminary

analysisStart = round(0.8*length(centroidCell));
cellThresh = round(.015*length(centroidCell{analysisStart}));
epsilon = 16;
minpts = 4;


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
titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
    analysisStart,cellThresh,epsilon,minpts);
gscatter(x(:,1),x(:,2),dbidx)
title(titleInfo)
%% Auto Calibration
clc
epsilon = 16;
minpts = 4;
[analysisStart,cellThresh,epsilon] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,'view');
%% Unsupervised Clustering
close all
clc
sizeI = 1.2;
tic
[polyCell,clusterCell,tr] = trackClusters(wellDates,centroidCell,sizeI,analysisStart,cellThresh,epsilon,minpts);
tr
toc
%% Quick Plotting
imRange = analysisStart:-1:1;
% imRange = analysisStart-1:-1:86;
% imRange = 80:-1:1;
close all
set(0,'DefaultFigureWindowStyle','docked')
quickPlotWell(wellDates,imRange,clusterCell,centroidCell,polyCell)
%% Export Movie
% imRangePlot = analysisStart:-1:1;
imRangePlot = 1:1:analysisStart;
set(0,'DefaultFigureWindowStyle','normal')
F = makeWellMovie(imRangePlot,fileName,polyCell,clusterCell,wellDates,centroidCell);
%% Create video
vw = VideoWriter(sprintf('%s_New.avi',fileName));
open(vw)
writeVideo(vw,F)
close(vw)