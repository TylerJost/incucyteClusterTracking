function F = makeWellMovie(imRangePlot,fileName,polyCell,clusterCell,dates,centroidCell)
%makeWellMovie makes a movie of the cluster growth and identification 
% imRangePlot is what frames the movie will use
% fileName is the name of the movie
% allPar has all of the circle information
% clusterCell has the cellCluster locations
% dates has the dates of each frame
% centroidCell has all the cell locations (as centroids)
close all
vw = VideoWriter(sprintf('%s_New.avi',fileName),'Motion JPEG AVI');
vw.Quality = 100;
open(vw);
h = figure('units','normalized','outerposition',[0 0 1 1]);
[allParSize,c] = size(polyCell);
% if length(allParSize)<3
%     nClusters = 1;
% else
%     nClusters = allParSize(3);
% end
nClusters = c;
fileParts = strsplit(fileName,'_');
experiment = fileParts{1};
well = fileParts{2}(1:end-4);
for im = imRangePlot
    subplot(121)
    % Plot all centroids
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),'.r')
    hold on
    title(string(dates{im}))
    % For each cluster plot the cluster and its circle
    cCount = 1;
    name = date2name(experiment,dates{im},well);
    imWell = imread(strcat(name,'.jpg'));
    for cluster = nClusters:-1:1
        % If there is a cluster, plot it
        if ~isempty(clusterCell{im,cluster})
            
            xyC = clusterCell{im,cluster};
            
            subplot(121)
            % Plot centroids and circles on plot
            % Recall we are checking a circle 2.5x the size of the cluster
%             circlePlot(allPar(im,1,cluster),allPar(im,2,cluster),allPar(im,3,cluster)*1.25)
            verts = polyCell{im,cluster};
            plot(verts(:,1),verts(:,2),':k','LineWidth',1.5)
            scatter(xyC(:,1),xyC(:,2),'.c')
            subplot(122)
            % Plot clusters on image with circle
            imWell = insertMarker(imWell, xyC, '*', 'Color', 'cyan');
            vertsPoly = zeros(1,length(verts)*2);
            vertsPoly(1:2:end) = verts(:,1); vertsPoly(2:2:end) = verts(:,2);
            imWell = insertShape(imWell,'Polygon',...
                vertsPoly,...
                'LineWidth',5);
            imshow(flipud(imWell))
            title(string(im))
        end
        cCount = cCount+1;
    end
    % If there are no clusters, just plot the images/centroids
    if all(cellfun(@isempty,clusterCell(im,:)))
        subplot(121)
        % Plot centroids
        xWhole = centroidCell{im};
        scatter(xWhole(:,1),xWhole(:,2),'.r')
        subplot(122)
        % Plot image
        imWell = imread(strcat(name,'.jpg'));
        imshow(flipud(imWell))
    end
    
    % Old code to save image as gif
%     frame = getframe(h);
%     img = frame2im(frame);
%     [imind,cm] = rgb2ind(img,256);
%     % Write to the GIF File
%     if im == max(imRangePlot)
%         imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);
%     else
%         imwrite(imind,cm,fileName,'gif','WriteMode','append');
%     end

    frame = getframe(h);
    writeVideo(vw,frame)
    clf
    
end
close(vw)
F = nan;
end