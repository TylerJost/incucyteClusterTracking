function [sizeFactors] = genSizeFactors(x,minVal,maxVal)
normRange = @(x,a,b) (b-a).*((x-min(x))./(max(x)-min(x)))+a;
x2 = linspace(1,100,length(x));
% y2 = exp(.03.*x2).*-1;
y2 = (maxVal./(1+exp(-0.15.*(x2-50)))).*-1+(maxVal+minVal);
sizeFactors = normRange(y2,minVal,maxVal);
end