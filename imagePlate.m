clc
clear
set(0,'DefaultFigureWindowStyle','normal')
close all
% Pick well
plateFolder = 'C:\Users\lucif\Box\Research\IncucyteData\GH1818';

% Load files from directory
files = dir(plateFolder);
files = {files.name};
files = files(3:end);
files = string(files);
nFiles = length(files);
% Find unique wells
wells = strings(nFiles,1);
dates = cell(nFiles,1);
for im = 1:nFiles
    fileComponents = strsplit(files(im),'_');
    wells(im) = fileComponents(2);
    % Extract date
    dateCap = fileComponents(4);
    timeCap = fileComponents(5);
    dates{im}  = datetime(str2double(dateCap{1}(1:4)),str2double(dateCap{1}(6:7)),...
    str2double(dateCap{1}(9:10)),...
    str2double(timeCap{1}(1:2)),str2double(timeCap{1}(4:5)),0);
    
end
uniqueWells = unique(wells);
%%
% For each well, image and find the centroid
cd(plateFolder)
for well = 1:length(uniqueWells)
    wellFilesI = find(wells == uniqueWells(well));
    centroidCell = cell(length(wellFilesI),1);
    centroidCount = zeros(length(wellFilesI),1);
    wellDates = dates(wellFilesI);
    wellFiles = files(wellFilesI);
    for wellFile = 1:length(wellFiles)
        fprintf('File %g/%g %s \n',wellFile,length(wellFiles),wellFiles(wellFile))
        centroidCell{wellFile} = cellCountProcessed(wellFiles(wellFile));
        centroidCount(wellFile) = length(centroidCell{wellFile});
    end
    fileNameSave = strcat(fileComponents(1),'_',uniqueWells(well),'.mat');
    save(fileNameSave,'centroidCell','wellDates','centroidCount')
end
% strcat(fileComponents(1),'_',fileComponents(2),'.mat')

% Load files from specific well
% files = {files.name};
% wells = strings(length(files),1);
% dates = cell(length(files),1);
% for i = 1:length(files)
%     [well,date] = nameMinerIncucyte(files{i});
%     wells(i) = string(well); dates{i} = date;
% end
% 
% 
% files = files(wells==wellName);
% dates = dates(wells==wellName);