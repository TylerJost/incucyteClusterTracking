function [polyCell,clusterCell,tr,dateInfo,genInfo] = trackClusters(dates,centroidCell,sizeI,analysisStart,cellThresh,epsilon,minpts,absMin,dbidx,tTreat)
%trackClusters finds clusters of cells and tracks them over time
% centroidCell is all locations of cells
% analysisStart is when the function should start tracking clusters
% cellThresh is the minimum number of cells for a cluster

% polyCell has polygon coordinates for the cluster
% clusterCell has coordinates of the centroids of each cluster
% tr is the tr calculation based on half life and time of treatment
% dateInfo has more date info based on clustering/half life

% Find initial large clusters
x = centroidCell{analysisStart};
% dbidx = dbscan(x,epsilon,minpts);
% New  Initial Cell Cluster
[C,ia,ic] = unique(dbidx);
counts = accumarray(ic,1);
clusterSizes = sortrows([C, counts],2,'descend');
clusterSizes(clusterSizes(:,1)==-1,:) = [];
% if epsilon>16
%     cellThresh = 350;
% end
% if cellThresh<150
%     cellThresh = 150;
% end
% clusterSizes(clusterSizes(:,2)<cellThresh,:) = [];
% clusterSizes(clusterSizes(:,2)<absMin,:) = [];
[nClusters,~] = size(clusterSizes);
primaryClusters = cell(1,nClusters);
for im = 1:length(primaryClusters)
    primaryClusters{im} = x(dbidx==clusterSizes(im,1),:);
end

% Preallocate allPar
imRange = analysisStart-1:-1:1;
clusterCell = cell(analysisStart,length(primaryClusters));
% Store polygon vertices in cell
polyCell = cell(size(clusterCell));
densCell = cell(size(polyCell));
densDiff = zeros(1,length(primaryClusters));

deCell = cell(size(clusterCell));
dcCell = cell(size(clusterCell));
edgeDistPercentCell = cell(size(clusterCell));
% Determine initial circle locations
currentVerts = cell(length(primaryClusters),1);
epsilonCluster = repmat(epsilon,length(primaryClusters),1);
minptsCluster = repmat(minpts,length(primaryClusters),1);
for cluster = 1:length(primaryClusters)
    xyC = primaryClusters{cluster};
    polyVerts = dilateHull(xyC,sizeI);
    
    currentVerts{cluster} = polyVerts;
    
    %     allPar(analysisStart,:,cluster) = [par(1),par(2),par(3)];
    clusterCell{analysisStart,cluster} = xyC;
    polyCell{analysisStart,cluster} = polyVerts;
end
sizeFactors = genSizeFactors(83:imRange(1),sizeI,2.5);
% perChangeArray = zeros(length(imRange),3);
for im = imRange
    xWhole = centroidCell{im};
%     clf
    % Find cluster for each identified major cluster
    %     for cluster = length(currentVerts):-1:1
    ncv = length(currentVerts);
    for cluster = 1:ncv
%         fprintf('\tCluster %g/%g\n',cluster,length(currentVerts))
        verts = currentVerts{cluster};
        % Check if new circle is significantly larger
        a2 = polyarea(verts(:,1),verts(:,2));
        a1 = polyarea(polyCell{im+1,cluster}(:,1),polyCell{im+1,cluster}(:,2));
        perChange = (a2-a1)/abs(a1)*100;
        perChangeArray(im,cluster) = perChange;
        % Large % Change/Cluster is active
        if (perChange)>50 && all(sum(verts) ~= 0)
            verts = polyCell{im+1,cluster};
            currentVerts{cluster} = verts;
            % THIS IS ALWAYS A BAD IDEA
%         elseif perChange<-50 && all(sum(verts) ~= 0)
%             verts = polyCell{im+1,cluster};
%             currentVerts{cluster} = verts;
        end
        % Find cell cluster in circle
        [xyC,~] = findCellCluster(xWhole,epsilonCluster(cluster),minptsCluster(cluster),0,currentVerts{cluster});
        % If a cluster isn't found, mark it
        if isempty(xyC) || ~iscell(xyC)
%             warning('Cluster %g not found \n',cluster)
            currentVerts{cluster} = [0 0];
            polyCell{im,cluster} = [0 0];
            continue
        end
        % Save old circle information
        for subcluster = 1:length(xyC)
            if subcluster>1
                % Add on new cluster if found (not computationally
                % efficient)
                cluster = length(currentVerts)+1;
            end
            polyCell{im,cluster} = verts;
            clusterCell{im,cluster} = xyC{subcluster};
            
            [newVerts,clusterA] = dilateHull(xyC{subcluster},sizeI);
                
            % Update values
            currentVerts{cluster} = newVerts;
            
            minptsCluster(cluster) = minpts;
            % Lower the epsilon value if we think it is an edge cluster
            edgeDistPercent = findEdgeClust(clusterCell(im,cluster),centroidCell(im));
            occurence = im/length(imRange)*100;

            
            [de, dc] = compEdgeDens(centroidCell{im},clusterCell{im,cluster},polyCell{im,cluster});
            
            edgeDistPercentCell{im,cluster} = edgeDistPercent;
            deCell{im,cluster} = de;
            dcCell{im,cluster} = dc;
            if edgeDistPercent<2 && occurence<40
                if dc-de<0
                    densDiff(cluster) = densDiff(cluster)+1;
                else
                    densDiff(cluster) = 0;
                end
                if densDiff(cluster)>=5
                    epsilonCluster(cluster) = 0;
                    warning('Edge cluster %g no longer dense, removing',cluster)
                    epsilonCluster
                end
                
                  % Lower epsilon value
%                 if epsilonCluster(cluster)-0.5>=12
%                     epsilonCluster(cluster) = epsilonCluster(cluster)-0.5;
%                 end
                % Compare density of cluster to density of edge
                
                
            else 
                epsilonCluster(cluster) = epsilon;
            end
            
        end
        epsilonCluster;
        densCell{im,cluster} = [de,dc];
        
    end
%     disp(length(currentVerts))
%     figure(1)
%     subplot(133)
%     scatter(xWhole(:,1),xWhole(:,2),'.k')
%     for i = 1:length(currentVerts)
%         cv = currentVerts{i};
%         hold on
%         plot(cv(:,1),cv(:,2))
%     end
    %     fprintf('Image %g/%g\n',im,length(imRange))
% Visualize
%         quickPlotWell(NaN,im,clusterCell,centroidCell,polyCell)
    
    
    % Error checking for too many clusters
    [~,currentNClusters] = size(clusterCell);
    if currentNClusters>20
        error('Too many clusters')
    end    
end
% figure()
% plot(imRange,[deCell{1:length(imRange),1}],'r')
% hold on
% plot(imRange,[dcCell{1:length(imRange),1}],'b')
% legend({'Edge Density', 'Cluster Density'})
disp(epsilonCluster)


% % Check if the cluster at the end is right next to the edge
% % near the time of treatment
% % Find closest image timepoint
% [~,tTreatIm] = min(abs(([dates{:}]-(hours(tTreat)+dates{1}))));
% % Fit circle to cells at time of treatment
% extrema = findClusterExtrema(centroidCell{tTreatIm});
% par = double(CircleFitByPratt(extrema));
% edgeClusterC = 1;
% edgeClusters = [];
% for cluster = 1:nClusters
%   % Find initial timepoint for each cluster
%   for tp = 1:length(clusterCell(:,cluster))
%       if ~isempty(clusterCell{tp,cluster})
%           emptyCell = tp;
%           break
%       end
%   end
% %   emptyCells = find(cellfun(@isempty,clusterCell(:,cluster)));
%   lastClusterPoly = polyCell{emptyCell,cluster};
%   [~,areaHull] = convhull(lastClusterPoly);
%   c = findPolygonCenter(lastClusterPoly,areaHull);
%   % Find what % edge distance is of radius
%   distEdge = (par(3)-euclid(c(1),par(1),c(2),par(2)))/par(3)*100;
%   disp(distEdge)
  % Validate/Visualize
%   figure(1)
%   hold on
%   verts = polyCell{emptyCell(end)+1,cluster};
%   plot(verts(:,1),verts(:,2),'--c','LineWidth',2)
%   scatter(centroidCell{tTreatIm}(:,1),centroidCell{tTreatIm}(:,2),'.k')
%   circlePlot(par(1),par(2),par(3))
%   scatter(c(1),c(2),100,'mx','LineWidth',2)
%   fprintf('Cluster %g: %g\n',cluster,distEdge)
  
  % Check if this polygon is too close to the edge to early to the time
  % of treatment
%   if distEdge<=5 && ...
%           dates{emptyCell(end)+1}-(dates{1}+hours(tTreat))<hours(72)
% %         scatter(c(1),c(2),100,'rx','LineWidth',2)
%         edgeClusters(edgeClusterC) = cluster;
%         edgeClusterC = edgeClusterC+1;
%   end
% end
% Find when cell cluster ended
[nDates,nClusters] = size(clusterCell);
tr = cell(nClusters,1);
dateInfo = cell(nClusters,2);
for cluster = 1:nClusters
    currentCluster = clusterCell(:,cluster);
    ccCount = zeros(length(currentCluster),1);
    for i = 1:length(ccCount)
        ccCount(i) = length(currentCluster{i});
    end

    for date = 1:nDates
        % Find the time to a cluster formation
        if ~isempty(clusterCell{date,cluster})
            ccCountInit = find(ccCount~=0);
            ccCountT = ccCount(1:ccCountInit(1)+.4*(length(ccCount)-ccCountInit(1)));
            x = 1:length(ccCountT);
            x = x(:);
            x0 = date; y0 = ccCount(date);
            g = @(p,x)y0*exp(p*(x-x0));
            f = fit(x,ccCountT,g);
            tDouble = log(2)/f.p;
            %                         figure
            %                         plot(f,x,ccCountT)
            %                         hold on
            numDouble = log(ccCount(date))/log(2);
            % date tells where the cluster disappears based on the polygon
            % tracking
            %
            % dateIndex tells where the cluster is supposed to disappear
            % considering time to double
            dateIndex = round(date-numDouble*tDouble);
            if dateIndex > 1 && dateIndex<=length(dates)
                tr{cluster} = dates{dateIndex}-dates{1};
                dateInfo{cluster,1} = dates{date};
                dateInfo{cluster,2} = dates{dateIndex};
            else
                tr{cluster} = dates{date}-dates{1};
                dateInfo{cluster,1} = dates{date};
                dateInfo{cluster,2} = NaN;
            end
            
            break
        end
    end
end
% Get rid of edge clusters
% genInfo = length(edgeClusters);
genInfo.densCell = densCell;


% for edgeCluster = length(edgeClusters):-1:1
%     polyCell(:,edgeClusters(edgeCluster)) = [];
%     clusterCell(:,edgeClusters(edgeCluster)) = [];
%     tr(edgeClusters(edgeCluster)) = [];
%     dateInfo(edgeClusters(edgeCluster),:) = [];
% end
end
