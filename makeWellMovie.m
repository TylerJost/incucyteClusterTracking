function F = makeWellMovie(imRangePlot,fileName,polyCell,clusterCell,dates,centroidCell,dateInfo,plotIm)
%makeWellMovie makes a movie of the cluster growth and identification
% imRangePlot is what frames the movie will use
% fileName is the name of the movie
% allPar has all of the circle information
% clusterCell has the cellCluster locations
% dates has the dates of each frame
% centroidCell has all the cell locations (as centroids)
close all
vw = VideoWriter(sprintf('%s.avi',fileName),'Motion JPEG AVI');
vw.Quality = 100;
open(vw);
if plotIm == 1
    h = figure('units','normalized','outerposition',[0 0 1 1]);
elseif plotIm == 0 || plotIm == -1
    h = figure('units','normalized','outerposition',[0.5 0 0.5 1]);
end

if iscell(polyCell)
    [allParSize,c] = size(polyCell);
elseif isnan(polyCell) || plotIm == -1
    c = 0;
    imRangePlot = length(centroidCell):-1:1;
else
    error('polyCell not recognized')
end
% if length(allParSize)<3
%     nClusters = 1;
% else
%     nClusters = allParSize(3);
% end
nClusters = c;
fileParts = strsplit(fileName,'_');
experiment = fileParts{1};
well = fileParts{2}(1:end-4);
% Set each shape to be a specific color
shapeC = ["blue", "green", "red", "cyan", "magenta", "yellow"];
% Make sure there are enough colors
shapeC = repmat(shapeC,1,ceil(c/length(shapeC)));
% for im = imRangePlot
clusterTitles = strings(nClusters,1);

for cluster = nClusters:-1:1
    if isdatetime(dateInfo{cluster,2})
        clusterTitles(cluster) =  sprintf('Cluster %g %s\n',cluster,string(dateInfo{cluster,2}));
    else
        clusterTitles(cluster) =  sprintf('Cluster %g %s\n',cluster,string(dateInfo{cluster,1}));
    end
end

for im  = imRangePlot(1:end)
    %     disp(im)
    %     subplot(121)
    % Plot all centroids
    xWhole = centroidCell{im};
    %     scatter(xWhole(:,1),xWhole(:,2),'.r')
    hold on
    title(string(dates{im}))
    % For each cluster plot the cluster and its circle
    cCount = 1;
    name = date2name(experiment,dates{im},well);
    legendTxt = gobjects(0);
    if plotIm == 0 || plotIm == -1
        hold on
        scatter(xWhole(:,1),xWhole(:,2),'.w')
    end

    for cluster = nClusters:-1:1
        
        
        
        % If there is a cluster, plot it
        if ~isempty(clusterCell{im,cluster})
            
            xyC = clusterCell{im,cluster};
            
            %             subplot(121)
            %             % Plot centroids and circles on plot
            %             % Recall we are checking a circle 2.5x the size of the cluster
            % %             circlePlot(allPar(im,1,cluster),allPar(im,2,cluster),allPar(im,3,cluster)*1.25)
            verts = polyCell{im,cluster};
            %             plot(verts(:,1),verts(:,2),':k','LineWidth',1.5)
            %             scatter(xyC(:,1),xyC(:,2),'.c')
            %             subplot(122)
            % Plot clusters on image with circle
            if plotIm == 1
                imWell = imread(strcat(name,'.jpg'));
                imWell = insertMarker(imWell, xyC, '*', 'Color', 'cyan');
                vertsPoly = zeros(1,length(verts)*2);
                vertsPoly(1:2:end) = verts(:,1); vertsPoly(2:2:end) = verts(:,2);
                imWell = insertShape(imWell,'Polygon',vertsPoly,'LineWidth',5,'Color',shapeC{cluster});
                imshow(flipud(imWell))
            elseif plotIm == 0
                scatter(xyC(:,1),xyC(:,2),'.','MarkerEdgeColor',shapeC{cluster})
                hold on
                plot(verts(:,1),verts(:,2),shapeC{cluster});
            end
            % Display Legend
            hold on
            
        end
        legendTxt(cluster) = plot(NaN,NaN,strcat("o", shapeC(cluster)),'DisplayName',sprintf('Cluster %g',cluster));
        currentDateName = string(dates{im});
        title(currentDateName)
        
        cCount = cCount+1;
        
    end
    if ~isempty(legendTxt) && plotIm ~=-1
        legend(legendTxt(1:end),'color','white')
    end
    
    annotation('textbox', [0, 1, 0, 0], 'string', clusterTitles)
    % If there are no clusters, just plot the images/centroids
    
    if iscell(clusterCell)
        if all(isempty(clusterCell)) || all(cellfun(@isempty,clusterCell(im,:)))
            legend('off')
            %         subplot(121)
            %         % Plot centroids
            %         xWhole = centroidCell{im};
            %         scatter(xWhole(:,1),xWhole(:,2),'.r')
            %         subplot(122)
            % Plot image
            if plotIm == 1
                imWell = imread(strcat(name,'.jpg'));
                imshow(flipud(imWell))
            elseif plotIm == 0
                scatter(xWhole(:,1),xWhole(:,2),'.w')
            end
        elseif ~iscell(clusterCell)
            if plotIm == 1
                imWell = imread(strcat(name,'.jpg'));
                imshow(flipud(imWell))
            elseif plotIm == 0
                scatter(xWhole(:,1),xWhole(:,2),'.w')
            end
            
        end
    end
    % Make legend
    
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
    set(gca,'Color','k')
    xlim([-1100,1100])
    ylim([-1100,1100])
    frame = getframe(h);
    writeVideo(vw,frame)
    
    clf
    
end
close(vw)
F = nan;
end