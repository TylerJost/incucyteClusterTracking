function makeWellGif(imRangePlot,fileName,allPar,clusterCell,dates,centroidCell)
close all
% set plotImage to 1 to view the actual image from incucyte
% plotImage = 1;
% What clustering we want to see
% imRangePlot = 130:-25:1;
% fileName = 'WellE6';
h = figure();
nClusters = size(allPar);
nClusters = nClusters(end);
for im = imRangePlot
    subplot(121)
%     Plot all data
    xWhole = centroidCell{im};
    scatter(xWhole(:,1),xWhole(:,2),'.r')
    hold on
    title(string(dates{im}))
    % For each cluster plot the cluster and its circle
    cCount = 1;
    
    for cluster = nClusters:-1:1
        if ~isempty(clusterCell{im,cluster})
            
            xyC = clusterCell{im,cluster};
            
            subplot(121)
            
            circlePlot(allPar(im,1,cluster),allPar(im,2,cluster),allPar(im,3,cluster)*2.5)
            scatter(xyC(:,1),xyC(:,2),'.c')
            subplot(122)
            name = date2name(dates{im},'E6');
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
    
    % Capture the plot as an image
    frame = getframe(h);
    img = frame2im(frame);
    [imind,cm] = rgb2ind(img,256);
    % Write to the GIF File
    if im == max(imRangePlot)
        imwrite(imind,cm,fileName,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,fileName,'gif','WriteMode','append');
    end
    clf
    
end
end