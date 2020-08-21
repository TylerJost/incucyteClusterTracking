function [edgeDistPercent, occurenceTime] = findEdgeClust(clusterCell, centroidCell,varargin)
% Find each cluster's earliest occurence
[nTP,nClusters] = size(clusterCell);
isCluster = ~cellfun(@isempty, clusterCell);
earliestOccurence = zeros(1,nClusters);

for clust = 1:nClusters
    for tp = 1:nTP
        if isCluster(tp,clust) == 1
            earliestOccurence(clust) = tp;
            break
        end
    end
end

% Find central distance from edge
edgeDistPercent = zeros(1,nClusters);
occurenceTime = zeros(1,nClusters);
for clust = 1:nClusters
    cluster = clusterCell{earliestOccurence(clust),clust};
    [k,aCluster] = convhull(double(cluster));
    centerPoly = findPolygonCenter([cluster(k,1),cluster(k,2)],aCluster);
    par = CircleFitByPratt(findClusterExtrema(double(centroidCell{tp})));
    c1 = par(1); c2 = par(2); r = par(3);
%     centerDist = euclid(c1,centerPoly(1),c2,centerPoly(2));
    centerDist = max(euclid(c1,cluster(:,1),c2,cluster(:,2)));
    edgeDistPercent(1,clust) = (r-centerDist)/r*100;
    occurenceTime(1,clust) = earliestOccurence(clust)/length(centroidCell)*100;
end

if ~isempty(varargin)
    if strcmp(varargin{1},'plot')
        scatter(centroidCell{1}(:,1),centroidCell{1}(:,2),'r.')
        hold on
        scatter(clusterCell{1}(:,1),clusterCell{1}(:,2),'b.')
        scatter(c1,c2,'mx')
        plot(centerPoly(1),centerPoly(2),'gx')
    end
end
end