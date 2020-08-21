% Compares edge densities
% %% Load Sample
% fileName = 'GH1825_C6.mat';
% load(fileName)
% set(0,'DefaultFigureWindowStyle','docked')
%
% if exist('outliers')
%     centroidCell(outliers) = [];
%     centroidCount(outliers) = [];
%     wellDates(outliers) = [];
% end
% [centroidCell, center] = centerWell(centroidCell);
%%
function [de, dc] = compEdgeDens(pts,clusterPts,clusterPoly)


pts = double(pts);
[k,areaHull] = convhull(pts);
ptsHull = [pts(k,1), pts(k,2)];
ptsHullSmall = ptsHull*.9;

% Find points around edge
in = inpolygon(pts(:,1),pts(:,2),ptsHullSmall(:,1),ptsHullSmall(:,2));

% Find densities
[~,areaHullS] = convhull(ptsHullSmall);
areaEdge = areaHull-areaHullS;
% pts/area of edge
de = sum(~in)/areaEdge;
% pts/area of cluster
if all(clusterPoly) == 0
    dc = 0;
else
    [~,areaCluster] = convhull(clusterPts);
    dc = length(clusterPts)/areaCluster;
end
% figure(1)
% clf
% plot(pts(:,1),pts(:,2),'.r')
% hold on
% plot(pts(~in,1),pts(~in,2),'gx')
% plot(ptsHull(:,1),ptsHull(:,2))
end