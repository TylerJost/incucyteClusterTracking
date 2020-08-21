clc
clear
close all
dataLocation = 'C:\Users\lucif\Box\Research\trCalculation\centroidData\GH1950';
cd(dataLocation)
files = dir('*.mat');
files = {files.name};
% files = files(3:end);
files = string(files);
%% Check if we need to do outlier detection
close all
for file = 1:length(files)
    load(files{file},'centroidCount','wellDates','outliers')
    wellDates = [wellDates{:}];
    figure(file)
    if exist('outliers')
       centroidCount(outliers) = []; 
       wellDates(outliers) = [];
    end
    plot(wellDates,centroidCount)
    title(files{file},'Interpreter', 'none')
    clear('centroidCount','wellDates','outliers')
end
%% Remove outliers
close all
clc
clearvars -except files
outliers = [];
for file = 1:length(files)
    load(files{file},'centroidCell','wellDates')
    wellDates = [wellDates{:}];
    % Count number of cells
    centroidCount = zeros(1,length(centroidCell));
    for centroid = 1:length(centroidCell)
        centroidCount(centroid) = length(centroidCell{centroid});
    end
    % Find outliers
    TF = isoutlier(centroidCount,'movmedian',hours(48),'ThresholdFactor',4,'SamplePoints',wellDates);
    %     TF = isoutlier(centroidCount,'movmedian',hours(48),'SamplePoints',wellDates);
    isZero = find(centroidCount == 0);
    TF(isZero) = 1;
    % Plot outliers
    figure(1)
    subplot(211)
    plot(wellDates,centroidCount)
    title(files{file},'Interpreter', 'none')
    hold on
    scatter(wellDates(TF),centroidCount(TF),100,'x','LineWidth',2)
    xlabel('Date')
    ylabel('Number of Cells')
    legend({'Cell Count','Outlier'})
    
    subplot(212)
    wellDates(TF) = NaT;
    centroidCount(TF) = NaN;
    plot(1:length(wellDates),centroidCount)
    
    fprintf('%s \t %.2g/%.2g \n', files{file},file,length(files));
    % Pause to mark outliers
    pause
    if ~isempty(outliers)
        autoOutliers = find(TF);
        outliers = [outliers(:,1); autoOutliers(:)];
        fprintf('\t %g manual %g auto outliers removed \n',length(outliers),length(autoOutliers))
    else
        warning("Be sure you didn't have any manual outliers")
        outliers = find(TF);
        autoOutliers = find(TF);
        fprintf('\t %g manual %g auto outliers removed \n',length(outliers),length(autoOutliers))
    end
    
    % Plot outliers to make sure it looks OK
    centroidCount(outliers) = [];
    wellDates(outliers) = [];
    plot(wellDates,centroidCount)
    %     plateStruct.(wells{well})('outliers') = outliers;
    
    % Save outliers to files, then set outliers to be empty
    save(files{file},'outliers','-append')
    outliers = [];
    clf
    clearvars -except outliers files file
end
close all