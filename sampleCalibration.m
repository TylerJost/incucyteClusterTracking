clear
clc
close all
fileName = 'GH1818_E6.mat';
% fileName = 'WellE6.mat';
% fileName = 'GH1818_B11.mat';
load(fileName)
set(0,'DefaultFigureWindowStyle','docked')
%%
clc
startPercent = 0.8;
decrease = 0.02;
while true
    analysisStart = round(startPercent*length(centroidCell));
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
 if max(clusterSizes)/length(x)>=0.6
     % Decrease by specified amount
     startPercent = startPercent - decrease;
     fprintf('Cluster too large (%g%%)\n',max(clusterSizes)/length(x)*100)
 else
     fprintf('Optimal cluster found (%g%%)\n',max(clusterSizes)/length(x)*100)
     break
 end
 if startPercent<=0.35
     disp('No optimal cluster found')
     break
 end
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