function [polyCell,clusterCell,tr] = trackClusters(dates,centroidCell,sizeI,analysisStart,cellThresh,epsilon,minpts)
%trackClusters finds clusters of cells and tracks them over time
% centroidCell is all locations of cells
% analysisStart is when the function should start tracking clusters
% cellThresh is the minimum number of cells for a cluster


% Find initial large clusters
x = centroidCell{analysisStart};
dbidx = dbscan(x,epsilon,minpts);
% Find primary clusters
% Store cluster sizes
[C,~,ic] = unique(dbidx);
counts = accumarray(ic,1);
cs = sortrows([C, counts],2,'descend');
cs(cs(:,1)==-1,:) = [];

% Separate clusters into cells
clusterI = find(cs(:,2)>cellThresh);
primaryClusters = cell(1,length(clusterI));
for im = 1:length(primaryClusters)
    primaryClusters{im} = x(dbidx == cs(clusterI(im),1),:);
end

% Preallocate allPar
imRange = analysisStart-1:-1:1;
clusterCell = cell(analysisStart,length(primaryClusters));
% Store polygon vertices in cell
polyCell = cell(size(clusterCell));
% Determine initial circle locations
currentVerts = cell(length(primaryClusters),1);
for cluster = 1:length(primaryClusters)
    xyC = primaryClusters{cluster};
    polyVerts = dilateHull(xyC,sizeI);
    
    currentVerts{cluster} = polyVerts;
    
    %     allPar(analysisStart,:,cluster) = [par(1),par(2),par(3)];
    clusterCell{analysisStart,cluster} = xyC;
    polyCell{analysisStart,cluster} = polyVerts;
end

% perChangeArray = zeros(length(imRange),3);
for im = imRange
    xWhole = centroidCell{im};
    % Find cluster for each identified major cluster
    %     for cluster = length(currentVerts):-1:1
    for cluster = 1:length(currentVerts)
        verts = currentVerts{cluster};
        % Check if new circle is significantly larger
        a2 = polyarea(verts(:,1),verts(:,2));
        a1 = polyarea(polyCell{im+1,cluster}(:,1),polyCell{im+1,cluster}(:,2));
        
        perChange = (a2-a1)/abs(a1)*100;
        % Large % Change/Cluster is active
        % Will need to make a way to ensure cluster is active or not ~~~
        if perChange>50 && all(sum(verts) ~= 0)
            verts = polyCell{im+1,cluster};
            currentVerts{cluster} = verts;
        end
        % Find cell cluster in circle
        [xyC,~] = findCellCluster(xWhole,epsilon,minpts,0,currentVerts{cluster});
        % If a cluster isn't found, mark it
        if isempty(xyC) || ~iscell(xyC)
            warning('Cluster %g not found \n',cluster)
            currentVerts{cluster} = [0 0];
            polyCell{im,cluster} = [0 0];
            continue
        end
        % Save old circle information
        for subcluster = 1:length(xyC)
            if subcluster>1
                cluster = length(currentVerts)+1;
            end
            polyCell{im,cluster} = verts;
            clusterCell{im,cluster} = xyC{subcluster};
            % Store new circle based on new clustering
            % Set minimum cluster area to be 18500
            [currentVerts{cluster},clusterA] = dilateHull(xyC{subcluster},sizeI);
%             minArea = 6000;
%             if clusterA<minArea
%                 sizeFactor = minArea/clusterA;
%                 [currentVerts{cluster}, ~] = dilateHull(xyC{subcluster},sizeFactor);
%             end
        end
    end
    fprintf('Image %g/%g\n',im,length(imRange))
%     quickPlotWell(NaN,im,clusterCell,centroidCell,polyCell)
end

% Find when cell cluster ended
[nDates,nClusters] = size(clusterCell);
tr = cell(nClusters,1);
for cluster = 1:nClusters
    for date = 1:nDates
        % Find the time to a cluster formation
        if ~isempty(clusterCell{date,cluster})
            tr{cluster} = dates{date}-dates{1};
            break
        end
    end
end
end