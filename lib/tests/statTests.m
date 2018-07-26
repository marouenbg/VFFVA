%%
%Recon2
VFFVA=readtable('largeModelsTime_VFFVA_LA.csv','Delimiter',',');
FVA=readtable('largeModelsTime_FFVA_LA.csv','Delimiter',',');
veryfast=zeros(3,5);
fast=zeros(3,5);
for k=1:3
    veryfast(k,:)=VFFVA.Recon2(k:3:15);
    fast(k,:)=FVA.Recon2(k:3:15);
end
figure;
subplot(2,2,1)
errorbar([2 4 8 16 32],mean(veryfast),std(veryfast),'Linewidth',2,'color','b');
hold on
errorbar([2 4 8 16 32],mean(fast),std(fast),'Linewidth',2,'color','r');
set(gca,'XTick',[2 4 8 16 32])
ylabel('Running time (s)')
xlabel('Threads')
set(gca,'fontsize',12)
grid on
title('Recon 2')
legend('veryfastFVA','fastFVA')

subplot(2,2,2)
for k=1:3
    veryfast(k,:)=VFFVA.Ematrix(k:3:15);
    fast(k,:)=FVA.Ematrix(k:3:15);
end
errorbar([2 4 8 16 32],mean(veryfast),std(veryfast),'Linewidth',2,'color','b');
hold on
errorbar([2 4 8 16 32],mean(fast),std(fast),'Linewidth',2,'color','r');
set(gca,'XTick',[2 4 8 16 32])
ylabel('Running time (s)')
xlabel('Threads')
set(gca,'fontsize',12)
title('E Matrix')
grid on
%%
%Ematrix coupled
VFFVA=readtable('EmatrixCoupledTime_VFFVA_LA.csv','Delimiter',',');
FVA=readtable('EmatrixCoupledTime_FFVA_LA.csv','Delimiter',',');
VFFVA16=readtable('EmatrixCoupledTime_VFFVA_LA_scheduele.csv','Delimiter',',');
%fetch running time and iterations
[schedueletime,iterationstime]=parseResultsFile();
for k=1:3
    veryfast(k,:)=VFFVA.Ematrix_coupled(k:3:15);
    fast(k,:)=FVA.Ematrix_coupled(k:3:15);
end

figure;
subplot(2,2,1)
errorbar([2 4 8 16 32],mean(veryfast),std(veryfast),'Linewidth',2,'color','b');
hold on
plot([16 16 16],VFFVA16.Ematrix_coupled,'x','color','b')
text([16 16 16],VFFVA16.Ematrix_coupled+[50 -50 50]',{'VFFVAstatic','VFFVAdynamic','VFFVAguided'})
errorbar([2 4 8 16 32],mean(fast),std(fast),'Linewidth',2,'color','r');
set(gca,'XTick',[2 4 8 16 32])
ylabel('Running time (s)')
xlabel('Threads')
set(gca,'fontsize',12)
grid on

subplot(2,2,3)
boxplot(schedueletime);
set(gca,'XTickLabel',{'static';'guided';'dynamic'})
xlabel('Running time per worker')
% set(gca,'fontsize',12)
ylabel('Time (s)')%compact style

subplot(2,2,4)
boxplot(iterationstime);
set(gca,'XTickLabel',{'static';'guided';'dynamic'})
% set(gca,'fontsize',12)
ylabel('Number of iterations ')
xlabel('Processed iterations per worker')
%%
%Harvey data
schedule=readtable('harvey1.csv','Delimiter',',');
colorSpecs=rand(3,4);
s = {'r+' 'o' '*' 'k^'};
figure;
subplot(2,2,1)
set(gca,'XTick',[2 4 8 16 32])
grid on
hold on;
%Matlab 
plot([8 16 32],[2165 1611 861],'-o','Color','y','MarkerFaceColor','y','MarkerEdgeColor','y','MarkerSize',9);
%chunk 500
plot([8 16 32],schedule.C500/60,['-' s{3}],'Color',colorSpecs(:,3),'MarkerFaceColor',colorSpecs(:,3),'MarkerEdgeColor',colorSpecs(:,3),'MarkerSize',9)
%chunk 100
plot([8 16 32],schedule.C100/60,['-' s{2}],'Color',colorSpecs(:,2),'MarkerFaceColor',colorSpecs(:,2),'MarkerEdgeColor',colorSpecs(:,2),'MarkerSize',9)
%chunk 50
plot([8 16 32],schedule.C50/60,['-' s{1}],'Color',colorSpecs(:,1),'MarkerFaceColor',colorSpecs(:,1),'MarkerEdgeColor',colorSpecs(:,1),'MarkerSize',9)
%guided
plot([8 16 32],schedule.guided/60,['-' s{4}],'Color',colorSpecs(:,4),'MarkerFaceColor',colorSpecs(:,4),'MarkerEdgeColor',colorSpecs(:,4),'MarkerSize',9)
%static
plot([8 16 32],schedule.static/60,'-x','Color','c','MarkerFaceColor','c','MarkerEdgeColor','c','MarkerSize',9)
%julia
plot([8 16 32],schedule.julia/60,'-x','Color','m','MarkerFaceColor','m','MarkerEdgeColor','m','MarkerSize',9)
ylabel('Running time (mn)')
xlabel('Threads')
set(gca,'fontsize',18)
legend('FFVA','VFFVA-500','VFFVA-100','VFFVA-50','VFFVA-guided','VFFVA-static','distributedFBA');
k=1;
for i={'8','16','32'}
    i
    k=k+1
    scheduleList={['dynamic,50' i{1}],['dynamic,100' i{1}],['dynamic,500' i{1}],['guided' i{1}]};
    [schedueletime,iterationstime]=parseResultsFile(scheduleList,str2num(i{1}));
    schedueletime = schedueletime/60; %transform to mn
    %8cores
    subplot(2,2,k)
    hold on;
    handels=[];
    for j=1:4
        colorSpec=colorSpecs(:,j);
        %chunk 50
        m=plot(iterationstime(:,j),schedueletime(:,j),s{j},'Color',colorSpec,'MarkerSize',9)
        handels=[handels m];
        %final time 50
        h=plot([min(min(iterationstime)) max(max(iterationstime))],[max(schedueletime(:,j)) max(schedueletime(:,j))],'color',colorSpec)
    end
    if isequal(i{1},'8')
        legend([handels h],{'chunk 50','chunk 100','chunk 500','guided','total time'})
    end
    set(gca,'fontsize',18)
    xlabel('Number of iterations processed per worker')
    ylabel('Time spent per worker')
end
%%
%Memory requirement
bar([1.32 2.576 4.874; 2.23*8 2.29*16 2.24*32;0.443*8 0.444*16 0.49*32])
set(gca,'XTickLabel',{'VFFVA';'FFVA';'distributedFBA'})
set(gca,'fontsize',18)
ylabel('Memory usage (Gb)')
legend('8 threads','16 threads','32 threads')
grid on
%%
%chunk size optimality
cd('P:\Projects\veryfastFVA\data\results')
titlePlot={'8 cores','16 cores','32 cores'};
figure;
for i=1:3
    subplot(1,3,i)
    plot([50 100 500 1000],table2array(schedule(i,3:6))/60,'linewidth',3)
    set(gca,'xtick',[50 100 500 1000])
    xlabel('Chunk size')
    ylabel('Time (mn)')
    set(gca,'fontsize',18);
    title(titlePlot(i))
end
