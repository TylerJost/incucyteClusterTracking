experiment = 'GH2003';
tTreatMap = createtTreatMat;
tTreatMat = tTreatMap(experiment);
%%
% a = 'BCDEFG';
% b = 2:11;
% wells = cell(60,1);
% c =1 ;
% for i = 1:length(a)
%     for j = 1:length(b)
%         wells{c} = strcat(a(i),string(b(j)));
%         c = c+1;
%     end
% end
%%
outputCell = {};
fileLoc = ['D:\Research\trCalculation\centroidData\',experiment];
files = dir(fileLoc);
files = {files.name};
files = files(3:end);
wells = cell(length(files),1);

for i = 1:length(wells)
   filesplit = strsplit(files{i},'_');
   wells{i} = filesplit{2}(1:end-4);
end
    
for i = 1:length(wells)
%     filename = strcat(experiment,'_',wells{i},'_trAnalysis.mat');
    load(fullfile(fileLoc,files{i}),'wellDates')
    wellDates = [wellDates{:}]';
    well = char(wells{i});
    tTreat = choosetTreat(tTreatMat, well,'well');
    dayTreat = wellDates(1)+hours(tTreat);
    [~,minPt] = min(abs(wellDates-dayTreat));
    outputCell{i,1} = well;
    outputCell{i,2} = minPt;
end
    
writecell(outputCell,[experiment,'_TreatIndex.csv'])
    