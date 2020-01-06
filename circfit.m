function   [xc,yc,R,a] = circfit(x,y)
%
%   [xc yx R] = circfit(x,y)
%
%   fits a circle  in x,y plane in a more accurate
%   (less prone to ill condition )
%  procedure than circfit2 but using more memory
%  x,y are column vector where (x(i),y(i)) is a measured point
%
%  result is center point (yc,xc) and radius R
%  an optional output is the vector of coeficient a
% describing the circle's equation
%
%   x^2+y^2+a(1)*x+a(2)*y+a(3)=0
%
%  By:  Izhak bucher 25/oct /1991,
x=x(:); y=y(:);
a=[x y ones(size(x))]\[-(x.^2+y.^2)];
xc = -.5*a(1);
yc = -.5*a(2);
R  =  sqrt((a(1)^2+a(2)^2)/4-a(3))*3;
% if nargin>2
%     if strcmp(varargin{1},'plot')
%         figure
%         circle(xc,yc,R)
%         hold on
%         scatter(x,y)
%     end
% end

end


% %try_circ_fit
% %
% % IB
% %
% % revival of a 13 years old code
% % Create data for a circle + noise
% 
% th = linspace(0,2*pi,20)';
% R=1.1111111;
% sigma = R/10;
% x = R*cos(th)+randn(size(th))*sigma;
% y = R*sin(th)+randn(size(th))*sigma;
% 
% plot(x,y,'o'), title(' measured points')
% pause(1)
% 
% % reconstruct circle from data
% [xc,yc,Re,a] = circfit(x,y);
% xe = Re*cos(th)+xc; ye = Re*sin(th)+yc;
% 
% plot(x,y,'o',[xe;xe(1)],[ye;ye(1)],'-.',R*cos(th),R*sin(th)),
% title(' measured fitted and true circles')
% legend('measured','fitted','true')
% text(xc-R*0.9,yc,sprintf('center (%g , %g );  R=%g',xc,yc,Re))
% xlabel x, ylabel y
% axis equal



