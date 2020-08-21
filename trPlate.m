% Calculate tr for all wells in a plate
clc
clear
%% Input
% Organize data such that all Incucyte images are in one folder
dataLocation = 'D:\Research\trCalculation\centroidData\GH1911';
% Ideally save in a different location
saveLocation = 'D:\Research\trCalculation\trAnalysis\GH1911';
% % Time of treatment for this plate
% tTreat = 45.4;
cd(saveLocation)
%% Load Well File Names
cd(dataLocation)
files = dir('*.mat');
files = {files.name};
% files = files(3:end);
files = string(files);

cd(saveLocation)
analysisFiles = dir('*.mat');
analysisFiles = {analysisFiles.name};
analysisFiles = analysisFiles(1:end);
analysisFiles = string(analysisFiles);

cd(dataLocation)
%% Analyze Wells
% Make a 60 well time of treatment matrix
% tTreatMat = repmat(45.4,6,10); % GH1818
% tTreatMat = [repmat(69,6,2), repmat(360,6,2), repmat(408,6,2), repmat(456,6,2), repmat(45,6,2)]; % GH1910
tTreatMat = zeros(6,10);
for file = 1:length(files)
    fileName = files(file);

    nameSplit = strsplit(fileName,'.');
    analysisName = [nameSplit{1},'_trAnalysis.mat'];
    fprintf('\tAnalyzing %s (%.2g%%)\n',fileName,file/length(files)*100)
%     if any(analysisFiles==analysisName)
%         fprintf('\tAlready Analyzed\n')
%         continue
%     end
    load(fileName,'centroidCell','centroidCount','wellDates','outliers')
    % Calibrate starting point for analysis
    epsilon = 26;
    minpts = 6;
    absMin = 150;
    tTreat = choosetTreat(tTreatMat, nameSplit);
    if exist('outliers')
        centroidCell(outliers) = [];
        centroidCount(outliers) = [];
        wellDates(outliers) = [];
    end
    
    try
        [analysisStart,cellThresh,epsilon,dbidx] = autoCalibrateAnalysisStart(centroidCell,epsilon,minpts,absMin);
    catch
        msgbox(sprintf('Problem calibrating %s',fileName))
        continue
    end
    % Track the clusters
    sizeI = 1.2;
    if ~isnan(analysisStart)
        lowestEpsilon = 15;
        while(true)
            % Try to track the clusters
            try
                [polyCell,clusterCell,tr,dateInfo,genInfo] = trackClusters(wellDates,centroidCell,sizeI,analysisStart,cellThresh,epsilon,minpts,absMin,dbidx,tTreat);
                if genInfo>0
                    msgbox(sprintf('%g edge clusters removed\nFile%s',genInfo,fileName))
                end
                cd(saveLocation)
                save(analysisName,'centroidCell','wellDates','analysisStart','cellThresh','polyCell','clusterCell','tr','dateInfo')
                break
                % If there is an error, lower the epsilon value
            catch
                epsilon = epsilon - 2;
            end
            if epsilon <= lowestEpsilon
                msgbox(sprintf('File %s could not be analyzed\n',fileName))
                polyCell = NaN; clusterCell = NaN; tr = NaN; dateInfo = NaN;
                msgbox(sprintf('File %s not analyzed \n',fileName))
                cd(saveLocation)
                save(analysisName,'centroidCell','wellDates','analysisStart','cellThresh','polyCell','clusterCell','tr','dateInfo')
                break
            end
        end
    else
        polyCell = NaN; clusterCell = NaN; tr = NaN; dateInfo = NaN;
        cd(saveLocation)
        save(analysisName,'centroidCell','wellDates','analysisStart','cellThresh','polyCell','clusterCell','tr','dateInfo')
    end
    
    clear('centroidCell','centroidCount','wellDates','outliers','wellDates','analysisStart','cellThresh','polyCell','clusterCell','tr','dateInfo')
end
disp('Done analyzing wells.')