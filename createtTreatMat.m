function [tTreatMap,skipMap] = createtTreatMat
echo off
% Generate a tTreatMa
tTreatCSV = readtable('tTreatCSV.csv');
[rows,~] = size(tTreatCSV);
tTreatMap = containers.Map();
for r = 1:rows
    if isempty(tTreatCSV{r,2}{1})
        name = tTreatCSV{r,1}{1};
        tTreatMat = zeros(8,12);
        tTreatMap(['GH',name]) = [];
        try
            load(['GH',name,'_B6.mat'],'wellDates')
            dateI = wellDates{1};
        catch
            warning('Well cannot be loaded for %s, try another well?',name)
            dateI = datetime('2000-01-01 00:00:00');
        end
    else
        cols = str2num(tTreatCSV{r,1}{1});
        tTreatDate = (tTreatCSV{r,2}{1});
        tTreat = hours(tTreatDate - dateI);
        for c = cols
            tTreatMat(:,c) = tTreat;
        end
    end
    tTreatMap(['GH',name]) = tTreatMat(2:7,2:11);
end

% Make skip map
% skips = readtable('columnSkips.csv');
% skipMap = containers.Map();
% experiments = unique(skips{:,1});
% for i = 1:length(experiments)
%     skipMap(string(experiments(i))) = [];
% end
% for i = 1:height(skips)
%     disp(i)
%     skipMap(string(skips{i,1})) = [skipMap(string(skips{i,1})), skips{i,2}];
% end
% skipMap('1818') = [];
% skipMap('1825') = [];
% skipMap('1909') = [];
end