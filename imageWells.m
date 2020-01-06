clc
clear
set(0,'DefaultFigureWindowStyle','normal')
close all

% Load files from directory
% files = dir('SampleWell');
% files = {files.name};
% files = files(3:end);

% Load files from specific well
files = dir('*.jpg');
files = {files.name};
wells = strings(length(files),1);
dates = cell(length(files),1);
for i = 1:length(files)
    [well,date] = nameMinerIncucyte(files{i});
    wells(i) = string(well); dates{i} = date;
end

% Pick well
wellName = 'C8';
files = files(wells==wellName);
dates = dates(wells==wellName);
%%
% Store the centroids of the cells and their count for each file
centroidCell = cell(length(files),1);
centroidCount = zeros(length(files),1);
for file = 1:1:length(files)
    fprintf('File %g/%g %s \n',file,length(files),files{file})
    centroidCell{file} = cellCountProcessed(files{file});
    centroidCount(file) = length(centroidCell{file});
end

save(['Well',wellName],'centroidCell','dates','centroidCount')