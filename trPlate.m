% Calculate tr for all wells in a plate
clc
clear
%% Input
% Organize data such that all Incucyte images are in one folder
dataLocation = 'C:\Users\lucif\Box\Research\trCalculation\Data\GH1818';
% Ideally save in a different location
saveLocation = 'C:\Users\lucif\Box\Research\trCalculation\trAnalysis';
%% Load Well File Names
cd(dataLocation)
files = dir('*.mat');
files = {files.name};
files = files(3:end);
files = string(files);

cd(saveLocation)
analysisFiles = dir('*.mat');
analysisFiles = {analysisFiles.name};
analysisFiles = analysisFiles(1:end);
analysisFiles = string(analysisFiles);
%% Analyze Wells
for file = 1:length(files)
    fileName = files(file);
    nameSplit = strsplit(fileName,'.');
    analysisName = [nameSplit{1},'_trAnalysis.mat'];
    fprintf('\tAnalyzing %s (%.2g%%)\n',fileName,file/length(files)*100)
    %     if any(analysisFiles==analysisName)
    %         fprintf('\tAlready Analyzed\n')
    %         continue
    %     end
    load(fileName)
    % Calibrate starting point for analysis
    epsilon = 16;
    minpts = 4;
    [analysisStart,cellThresh,epsilon] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts);
    % Track the clusters
    sizeI = 1.2;
    if ~isnan(analysisStart)
        [polyCell,clusterCell,tr] = trackClusters(wellDates,centroidCell,sizeI,analysisStart,cellThresh,epsilon,minpts);
    else
        polyCell = NaN; clusterCell = NaN; tr = NaN;
    end
    cd(saveLocation)
    save(analysisName,'centroidCell','wellDates','analysisStart','cellThresh','polyCell','clusterCell','tr')
end