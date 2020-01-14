function F = makeWellMovie(imRangePlot,fileName,allPar,clusterCell,dates,centroidCell)
%makeWellMovie makes a movie of the cluster growth and identification 
% imRangePlot is what frames the movie will use
% fileName is the name of the movie
% allPar has all of the circle information
% clusterCell has the cellCluster locations
% dates has the dates of each frame
% centroidCell has all the cell locations (as centroids)
close all
h = figure();
allParSize = size(allPar);
if length(allParSize)<3
    nClusters = 1;
else
    nClusters = allParSize(3);
end
for im = imRangePlot
    subplot(121)
    % Plot all centroids
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),'.r')
    hold on
    title(string(dates{im}))
    % For each cluster plot the cluster and its circle
    cCount = 1;
    for cluster = nClusters:-1:1
        % If there is a cluster, plot it
        if ~isempty(clusterCell{im,cluster})
            
            xyC = clusterCell{im,cluster};
            
            subplot(121)
            % Plot centroids and circles on plot
            % Recall we are checking a circle 2.5x the size of the cluster
            circlePlot(allPar(im,1,cluster),allPar(im,2,cluster),allPar(im,3,cluster)*2.5)
            scatter(xyC(:,1),xyC(:,2),'.c')
            subplot(122)
            % Plot clusters on image with circles
            % Will need to update this, otherwise the images won't read
            % right
            name = date2name(dates{im},'B3');
            if cCount == 1
                imWell = imread(strcat(name,'.jpg'));
            else
                imWell = imCheck;
            end
            imCheck = insertMarker(imWell, xyC, '*', 'Color', 'cyan');
            imCheck = insertShape(imCheck,'circle',...
                [allPar(im,1,cluster),allPar(im,2,cluster),allPar(im,3,cluster)*2.5],...
                'LineWidth',5);
            imshow(flipud(imCheck))
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

    F(im) = getframe(h);
    clf
    
end
% Create video
vw = VideoWriter(sprintf('%s.avi',fileName));
open(vw)
writeVideo(vw,F)

end