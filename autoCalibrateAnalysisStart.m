function [analysisStart, cellThresh] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,varargin)
%autoCalibrateAnalysisStart decides where to start analyzing cell clusters
% The program looks for a single cluster <= 60% of the total number of
% cells.
%
% The program is heavily bottlenecked by the function dbscan, and is most
% improved by decreasing when the program starts, as searching through a
% large number of data points (ie cells) is highly inefficient.

% When to start looking for clusters
startPercentInit = 0.8;
% How much to decrease each time
decrease = 0.02;
% The absolute minimum number of cells for a cluster
absMin = 150;
% Minimum percentage of total cells
minCellPerc = 0.015;
% Minimum percentage for a cluster's size
minClusterPerc = 0.6;
% Minimum start percent
minStartPerc = 0.35;
while true
    analysisStart = round(startPercentInit*length(centroidCell));
    cellThresh = round(minCellPerc*length(centroidCell{analysisStart}));
    
    x = centroidCell{analysisStart};
    dbidx = dbscan(x,epsilon,minpts);
    % Use cellThresh to get rid of small cell clusters
    clusters = unique(dbidx(dbidx>0));
    clusterSizes = zeros(length(clusters),1);
    % Store cluster sizes
    for im = 1:length(clusters)
        clusterSizes(im) = sum(dbidx==clusters(im));
    end
    if isempty(clusterSizes)
        clusterSizes = 0;
    end
    % Calculate what % of largest cluster
    clusterPercent = max(clusterSizes)/length(x);
    % Decrease faster if cluster is sufficiently large to save time
    if clusterPercent>=0.9
        decrease = 0.07;
    else
        decrease = 0.02;
    end
    % If the cluster is extremely small then we don't want to use it
    % While unlikely, continue search earlier if
    if max(clusterSizes)<absMin && startPercentInit <= 0.35
        analysisStart = NaN; cellThresh = NaN;
        disp('No optimal cluster found (cluster too small)')
        return
    elseif max(clusterSizes)<absMin
        startPercentInit = startPercentInit - decrease;
        disp('Cluster too small')
        continue
    end
    
    % If the cluster is too large, move to an earlier timepoint
    % Otherwise, we have succeeded
    if clusterPercent>=minClusterPerc
        % Decrease by specified amount
        startPercentInit = startPercentInit - decrease;
        fprintf('Cluster too large (%g%%)\n',max(clusterSizes)/length(x)*100)
    else
        fprintf('Optimal cluster found (%g%%)\n',max(clusterSizes)/length(x)*100)
        break
    end
    if startPercentInit<=minStartPerc
        disp('No optimal cluster found (cluster too large)')
        analysisStart = NaN; cellThresh = NaN;
        return
    end
end
% Get rid of small clusters
clusterI = find(clusterSizes>cellThresh);
for im = 1:length(dbidx)
    if isempty(find(dbidx(im) == clusterI,1))
        dbidx(im) = -1;
    end
end
% Plot data
if ~isempty(varargin) && strcmp(varargin{1},'view')
    clf
    figure()
    titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
        analysisStart,cellThresh,epsilon,minpts);
    gscatter(x(:,1),x(:,2),dbidx)
    title(titleInfo)
end
end