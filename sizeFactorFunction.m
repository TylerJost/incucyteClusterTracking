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
%% Function fitting
c = [1 -2 1 -1];  
x = linspace(-2,4);  
y = c(1)*x.^3+c(2)*x.^2+c(3)*x+c(4) + randn(1,100);
plot(x,y,'.b-')
hold on
c = polyfit(x,y,3);  
yhat = c(1)*x.^3+c(2)*x.^2+c(3)*x+c(4);
plot(x,yhat,'r','linewidth',2)
% Linear constraint
x0 = 0;
y0 = 0;
x = x(:); %reshape the data into a column vector
y = y(:);
% 'C' is the Vandermonde matrix for 'x'
n = 3; % Degree of polynomial to fit
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
     V(:,j) = x.*V(:,j+1);
end
C = V;
% 'd' is the vector of target values, 'y'.
d = y;
% There are no inequality constraints in this case, i.e., 
A = [];
b = [];
% We use linear equality constraints to force the curve to hit the required point. In
% this case, 'Aeq' is the Vandermoonde matrix for 'x0'
Aeq = x0.^(n:-1:0);
% and 'beq' is the value the curve should take at that point
beq = y0;
p = lsqlin( C, d, A, b, Aeq, beq );
% We can then use POLYVAL to evaluate the fitted curve
yhat = polyval( p, x );
% Plot original data
plot(x,y,'.b-') 
hold on
% Plot point to go through
plot(x0,y0,'gx','linewidth',4) 
% Plot fitted data
plot(x,yhat,'r','linewidth',2) 
hold off