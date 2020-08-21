clc
clear
close all
load('HW2b.mat')
% Plot data for HW
n = length(fracStore);
legendTxt = cell(n,1);
for i = 1:n
    legendTxt{i} = sprintf('Num frac = %g\nTot Dose = %g',fracStore(i),doseStore(i));
end


figure(1)
subplot(121)
for i = 1:n
    hold on
    plot(linspace(0,30,length(s2taStore)),s2taStore(:,i),'linewidth',2)
end
xlabel('Time (days)','FontSize',20)
ylabel('avg drug concentration','FontSize',20)
set(gca,'FontSize',20,'LineWidth',2)
legend(legendTxt)