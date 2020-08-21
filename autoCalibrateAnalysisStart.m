function [analysisStart, cellThresh, epsilon, dbidx] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,absMin,wellDates,tTreat,varargin)
%autoCalibrateAnalysisStart decides where to start analyzing cell clusters
% The program looks for a single cluster <= 60% of the total number of
% cells.
%
% The program is heavily bottlenecked by the function dbscan, and is most
% improved by decreasing when the program starts, as searching through a
% large number of data points (ie cells) is highly inefficient.

% When to start looking for clusters
startPercentInit = 1;

% The absolute minimum number of cells for a cluster
% absMin = 200;
% Minimum percentage of total cells
minCellPerc = 0.015;
% Maximum percentage for a cluster's size
maxClusterPerc = 0.7;
% Minimum start percent
minStartPerc = 0.35;

clusterFound = 1;

% Find percentage of experiment when treatment was applied
[~,treatIndex] = min(abs([wellDates{:}]-(wellDates{1}+hours(tTreat))));
treatPercent = treatIndex/length(wellDates);
% If this time of treatment is past the minimum start percent, 
if treatPercent>minStartPerc
    minStartPerc = treatPercent;
end

% How much to decrease each time
minDecrease = 2/length(centroidCell)-1/length(centroidCell);
percArray = linspace(startPercentInit,minStartPerc,30);
decrease = percArray(1)-percArray(2);
if decrease<minDecrease
    decrease = minDecrease;
end
decreaseO = decrease;
epsilonO = epsilon;
while true
    % fprintf('\tSearching at %g%%\n',startPercentInit*100)
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
    
    % In case of visualization
%     gscatter(x(:,1),x(:,2),dbidx,lines(6))
    
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

%     disp(clusterPercent)
    % Decrease faster if cluster is sufficiently large to save time
    if clusterPercent>=0.9
        decrease = decreaseO*3.5;
    else
        decrease = decreaseO;
    end
    % If the cluster is extremely small then we don't want to use it
    % If the cluster is too small/we are starting too late/epsilon is large
    % the cluster is too small
    % if max(clusterSizes)<=absMin && startPercentInit <= minStartPerc && epsilon>=26
    if startPercentInit <= minStartPerc && epsilon>=epsilonO + 4
        analysisStart = NaN; cellThresh = NaN; dbidx = NaN;
        disp('No optimal cluster found (cluster too small)')
        clusterFound = 0;
        break
        % If epsilon is sufficiently small, increase it and start from the
        % beginning.
    elseif max(clusterSizes)<=absMin && epsilon< epsilonO + 4 && startPercentInit <= minStartPerc
        epsilon = epsilon+2;
        startPercentInit = 1;
        fprintf('Restarting search, epsilon = %g\n',epsilon);
        continue
    elseif max(clusterSizes)<absMin
        if max(clusterSizes)<absMin && startPercentInit<=minStartPerc
            clusterFound = 0;
            break
        end
        startPercentInit = startPercentInit - decrease;
        fprintf('Cluster too small (%g%%)\n',max(clusterSizes)/length(x)*100)
        continue
    end
    
    % If the cluster is too large, move to an earlier timepoint
    % Otherwise, we have succeeded
    if clusterPercent>=maxClusterPerc && startPercentInit<=minStartPerc
        disp('No optimal cluster found (cluster too large)')
        analysisStart = NaN; cellThresh = NaN; dbidx = NaN;
        clusterFound = 0;
        return
    elseif clusterPercent>=maxClusterPerc
        % Decrease by specified amount
        startPercentInit = startPercentInit - decrease;
        if startPercentInit<=minStartPerc
            analysisStart = NaN; cellThresh = NaN; dbidx = NaN;
            clusterFound = 0;
            break
        end
        fprintf('Cluster too large (%g%%)\n',max(clusterSizes)/length(x)*100)
    elseif max(clusterSizes)>=absMin && startPercentInit>=minStartPerc
        fprintf('Optimal cluster found (%g%%)\n',max(clusterSizes)/length(x)*100)
        break
    elseif startPercentInit<=minStartPerc %&& clusterPercent>=maxClusterPerc
        fprintf("\tCluster Not Found in Range \n")
        analysisStart = NaN; cellThresh = NaN; dbidx = NaN;
        clusterFound = 0;
        break
    end
end
% Get rid of small clusters
clusterI = find(clusterSizes>=cellThresh& clusterSizes>=absMin);

for im = 1:length(dbidx)
    if isempty(find(dbidx(im) == clusterI,1))
        dbidx(im) = -1;
    end
end

% Plot data
if ~isempty(varargin)
    if(strcmp(varargin{1},'viewall'))
        if clusterFound == 0
            figNo = 1;
            for im = round(linspace(length(centroidCell),1,6))
                pts = centroidCell{im};
                figure(1)
                subplot(2,3,figNo)
                scatter(pts(:,1),pts(:,2),'.r')
                title(sprintf('%g%%',im/length(centroidCell)*100))
                figNo = figNo+1;
            end
        else
            clf
            figure()
            titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
                analysisStart,cellThresh,epsilon,minpts);
            gscatter(x(:,1),x(:,2),dbidx)
            title(titleInfo)
        end
    elseif(strcmp(varargin{1},'view'))
        if clusterFound ~= 0
            titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
                analysisStart,cellThresh,epsilon,minpts);
            gscatter(x(:,1),x(:,2),dbidx)
            title(titleInfo)
        else
            ims = round(linspace(.2*length(centroidCell),.8*length(centroidCell),6));
            for figNo = 1:6
                subplot(2,3,figNo)
                x = centroidCell{ims(figNo)};
                scatter(x(:,1),x(:,2),'.r')
                title(string(ims(figNo)))
            end
        end
    end
    drawnow()
    fprintf('\nCluster Counts\n')
    [C,~,ic] = unique(dbidx);
    counts = accumarray(ic,1);
    disp(sortrows([C, counts],2,'descend'))
end

end