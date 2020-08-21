%% Load Data
clearvars -except plateStruct
clc
close all
% fileName = 'GH1818_F7.mat'; % Poor cluster splitting
% fileName = 'GH1818_E3.mat'; % Non-dense well
% fileName = 'GH1818_E6.mat'; % Ideal-case well
% fileName = 'GH1818_B3.mat'; % Cutting off too early
% fileName = 'GH1818_E5.mat'; % Current problem child
% GH2003
% fileName = 'GH2003_B8.mat';
% fileName = 'GH2003_C8.mat';
% fileName = 'GH2003_C9.mat';
% fileName = 'GH2003_B10.mat';

% fileName = 'GH1910_C10.mat';
fileName = 'GH1909_B7.mat';
% fileName = 'GH2003_F10.mat';
load(fileName)
set(0,'DefaultFigureWindowStyle','docked')

if exist('outliers')
    centroidCell(outliers) = [];
    centroidCount(outliers) = [];
    wellDates(outliers) = [];
end
[centroidCell, center] = centerWell(centroidCell);

%% Calibration
% figure()
% % Initial values to alter
% % Minimum number of cells for a cluster to start with
% % epsilon is the radius which checks for other core points
% % minpts is the minimum number of points that can be reached using epsilon
% %
% % For more explanation on DBSCAN see: 
% % https://en.wikipedia.org/wiki/DBSCAN#Preliminary
% 
% analysisStart = round(0.8*length(centroidCell));
% cellThresh = round(.1*length(centroidCell{analysisStart}));
% epsilon = 26;
% minpts = 6;
% 
% 
% x = centroidCell{analysisStart};
% dbidx = dbscan(x,epsilon,minpts);
% dbidxO = dbidx;
% % Use cellThresh to get rid of small cell clusters
% clusters = unique(dbidx(dbidx>0));
% clusterSizes = zeros(length(clusters),1);
% subplot(121)
% gscatter(x(:,1),x(:,2),dbidx)
% title(fileName,'Interpreter', 'none')
% % Store cluster sizes
% for im = 1:length(clusters)
%     clusterSizes(im) = sum(dbidx==clusters(im));
% end
% % Get rid of small clusters
% clusterI = find(clusterSizes>cellThresh);
% for im = 1:length(dbidx)
%     if isempty(find(dbidx(im) == clusterI,1))
%        dbidx(im) = -1;         
%     end
% end
% subplot(122)
% titleInfo = sprintf('Analysis Start = %g\nCell Thresh = %g\nepsilon = %g\nminpts=%g',...
%     analysisStart,cellThresh,epsilon,minpts);
% gscatter(x(:,1),x(:,2),dbidx)
% title(titleInfo)
%% tTreatDiff
% 1915 - 1:10 PM 5/22/19
%
%                          _____________tr______________
% ----|--------------------|---------------------------|-------------------
% Exp Start          First Treat               Cluster Begins
nameSplit = strsplit(fileName,'_');
experiment = nameSplit{1};
wellSplit = strsplit(nameSplit{2},'.');
well = wellSplit{1};
tTreatMap = createtTreatMat;
tTreatMat = tTreatMap(experiment);
%% Auto Calibration
clc
% MCF7
epsilon = 30;
minpts = 4;
absMin = 150;
sizeI = 1.4;

% % 231
% epsilon = 45;
% minpts = 14;
% [centroidCell,centers] = centerWell(centroidCell);
tic
tTreat = choosetTreat(tTreatMat, well,'well');

% analysisFolder = 'D:\Research\testDataGH1825\24_5_150\wellsCalibration';
analysisFolder = 'C:\Users\lucif\Box\Brock Lab Private (UT Collaborators only)\Tyler Jost\IncucyteData\';
experiment = strsplit(fileName,'_');
experiment = experiment{1};
parameters = strjoin([string(epsilon),string(minpts),string(absMin)],'_');
analysisFolder = fullfile(analysisFolder,experiment,parameters,'wellsCalibration');


calibrationName = [fileName(1:end-4),'_Calibration.mat'];

% if ~isfile(fullfile(analysisFolder,calibrationName))
    disp('Calibrating starting conditions')
    [analysisStart,cellThresh,epsilon,dbidx] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,absMin,wellDates,tTreat,'viewall');
%     save(fullfile(analysisFolder,[fileName(1:end-4),'_Calibration']))
% else
%     disp('Skipping calibration step!')
%     load(fullfile(analysisFolder,calibrationName))
%     epsilon = epsilonT;
% end
toc

%% Unsupervised Clustering
tic
epsilonT = epsilon;
while epsilonT>epsilon-1
    [polyCell,clusterCell,tr,dateInfo,genInfo] = trackClusters(wellDates,centroidCell,sizeI,analysisStart,cellThresh,epsilonT,minpts,absMin,dbidx,tTreat);
    [edgeDistPercent, occurence] = findEdgeClust(clusterCell, centroidCell);
    % Get rid of edge clusters
    edgeClusters = find(edgeDistPercent<10 & occurence<12);
    % Only act if they are not all edge clusters
%     if length(edgeClusters) ~= length(edgeDistPercent)
%         % Remove edge clusters
%         for clust = length(edgeClusters):-1:1
%             clusterI = edgeClusters(clust);
%             polyCell(:,clusterI) = [];
%             clusterCell(:,clusterI) = [];
%             tr(clusterI) = [];
%             dateInfo(clusterI,:) = [];
%         end
%     elseif epsilonT == epsilon-5
%         msgbox(sprintf('File %s had only unresolved edge clusters',fileName))
%     end
    wellSnapshot(clusterCell,wellDates,centroidCell,polyCell,analysisStart,epsilonT,minpts,absMin,nameSplit{1},sizeI)
    if min(hours([tr{:}]))<tTreat
        epsilonT = epsilonT-1;
    else
        break
    end
    
end
dates = [wellDates{:}]';
tr
toc
%% Quick Plotting
% % Find last time cluster is found
% emptyClusters = cellfun(@isempty,clusterCell);
% allEmpty = find(all(emptyClusters==1,2));
% if ~isempty(allEmpty)
% analysisEnd = allEmpty(end);
% else
%     analysisEnd = 1;
% end
% %
% close all
% % imRange = analysisStart:-1:1;
% imRange = 65-1:-1:59;
% imRange = analysisStart:-1:analysisEnd;
% % imRange = 215:-1:200;
% close all
% set(0,'DefaultFigureWindowStyle','docked')
% pos = [1     1   771   916];
% figure('Position',pos)
% quickPlotWell(wellDates,imRange,clusterCell,centroidCell,polyCell,'subplot')
% imRange = round(linspace(imRange(1),imRange(end),6));
% perc = imRange./length(centroidCell)*100;
% for i = 1:length(perc)
%     subplot(3,2,i)
%     title(sprintf('%.2f%% \n %s',perc(i),wellDates{imRange(i)}))
% end
%% Export Movie
% imRangePlot = 1:1:analysisStart;
% set(0,'DefaultFigureWindowStyle','default')
% F = makeWellMovie(imRangePlot,fileName,polyCell,clusterCell,wellDates,centroidCell,dateInfo,0);