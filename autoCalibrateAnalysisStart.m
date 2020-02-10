function [analysisStart, cellThresh, epsilon] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,varargin)
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
absMin = 350;
% Minimum percentage of total cells
minCellPerc = 0.015;
% Maximum percentage for a cluster's size
maxClusterPerc = 0.6;
% Minimum start percent
minStartPerc = 0.35;

clusterFound = 1;
while true
    fprintf('\tSearching at %g%%\n',startPercentInit*100)
    % If the clusters are not very dense, increase how many cells for a
    % minimum cluster to encourage epsilon to grow as high as necessary
%     if epsilon>16
%         minCellPerc = 0.025;
%     end
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
    % If the cluster is too small/we are starting too late/epsilon is large
    % the cluster is too small
    if max(clusterSizes)<absMin && startPercentInit <= minStartPerc && epsilon>=26
        analysisStart = NaN; cellThresh = NaN;
        disp('No optimal cluster found (cluster too small)')
        clusterFound = 0;
        break
        % If epsilon is sufficiently small, increase it and start from the
        % beginning.
    elseif max(clusterSizes)<absMin && epsilon<26 && startPercentInit <= minStartPerc
        epsilon = epsilon+2;
        startPercentInit = 0.8;
        fprintf('Restarting search, epsilon = %g\n',epsilon);
        continue
    elseif max(clusterSizes)<absMin
        startPercentInit = startPercentInit - decrease;
        fprintf('Cluster too small (%g%%)\n',max(clusterSizes)/length(x)*100)
    end
    
    % If the cluster is too large, move to an earlier timepoint
    % Otherwise, we have succeeded
    if clusterPercent>=maxClusterPerc && startPercentInit<=minStartPerc
        disp('No optimal cluster found (cluster too large)')
        analysisStart = NaN; cellThresh = NaN;
        return
    elseif clusterPercent>=maxClusterPerc
        % Decrease by specified amount
        startPercentInit = startPercentInit - decrease;
        fprintf('Cluster too large (%g%%)\n',max(clusterSizes)/length(x)*100)
    elseif max(clusterSizes)>absMin && startPercentInit>=minStartPerc
        fprintf('Optimal cluster found (%g%%)\n',max(clusterSizes)/length(x)*100)
        break
    elseif startPercentInit<=minStartPerc && clusterPercent>=maxClusterPerc
        analysisStart = NaN; cellThresh = NaN;
        clusterFound = 0;
        break
    end
end
    % Get rid of small clusters
    clusterI = find(clusterSizes>cellThresh& clusterSizes>absMin);
    
    for im = 1:length(dbidx)
        if isempty(find(dbidx(im) == clusterI,1))
            dbidx(im) = -1;
        end
    end
    
    % Plot data
    if ~isempty(varargin) && strcmp(varargin{1},'view')
        close all
        if clusterFound == 0
            for im = round(linspace(length(centroidCell),1,6))
                pts = centroidCell{im};
                figure(im)
                scatter(pts(:,1),pts(:,2),'.r')
            end
        else
            clf
            figure()
            titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
                analysisStart,cellThresh,epsilon,minpts);
            gscatter(x(:,1),x(:,2),dbidx)
            title(titleInfo)
        end
        fprintf('\nCluster Counts\n')
        [C,~,ic] = unique(dbidx);
        counts = accumarray(ic,1);
        disp(sortrows([C, counts],2,'descend'))
    end
    
end