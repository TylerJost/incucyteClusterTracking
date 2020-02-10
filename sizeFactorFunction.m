figure
plot(1:100,1:100)
[x,y] = ginput(10);
p = polyfit(x,y,4);
p = [ -0.0000    0.0003   -0.0168    0.0432   92.5756];
x1 = linspace(0,100,1000);
y1 = polyval(p,x1);
figure
plot(x,y,'o')
hold on
plot(x1,y1)

%%
normRange = @(x,a,b) (b-a).*((x-min(x))./(max(x)-min(x)))+a;
imRangeNorm = normRange(imRange,1,100);
% valsNorm = normRange(

%%
x2 = 1:100;
y2 = exp(.03.*x2).*-1;
y2 = y2+abs(min(y2));
figure(1)
plot(x2,y2)
figure(2)
y2 = normRange(y2,1.1,2.2);
plot(x2,y2)

sizeFactors = genSizeFactors(imRange,1.1,2.2);
imRangePercent = linspace(1,100,length(imRange));
figure(3)
plot(imRangePercent,sizeFactors)
%%
x2 = linspace(0,100,length(imRange));
y2 = (2.2./(1+exp(-0.15.*(x2-50)))).*-1+2.2;
plot(x2,y2)