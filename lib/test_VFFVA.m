nCores=1;
nThreads=4;
%add cobratoolbox and VFFVA to path
addpath(genpath('cobratoolbox'))
addpath(genpath('VFFVA'))
cd('VFFVA/lib')
model='../data/models/Ecoli_core/Ecoli_core.mps';

%.mps model
[minFlux,maxFlux]=VFFVA(nCores, nThreads, model);

%COBRA model - uncoupled
load ecoli_core_model.mat
ecoli=model;
[minFluxVFFVA,maxFluxVFFVA]=VFFVA(nCores, nThreads, ecoli);

%COBRA model - coupled
load EMatrix_LPProblemtRNACoupled90.mat
model=LPProblemtRNACoupled90;
[minFlux,maxFlux]=VFFVA(nCores, nThreads, model);

%compare to FVA from COBRA toolbox
changeCobraSolver('ibm_cplex');
optPercentage=90;
[minFluxFVA,maxFluxFVA]=fluxVariability(ecoli, optPercentage);
figure;
plot([minFluxVFFVA;maxFluxVFFVA],[minFluxFVA;maxFluxFVA],'o','MarkerSize',8,...
    'MarkerFaceColor','b')
hold on;
%set(gca, 'XScale', 'log', 'YScale', 'log')
plot([-40 1000],[-40 1000],'LineWidth',1);
ax=gca;
ax.FontSize=12;
xlabel('VFFVA fluxes','FontSize',18); ylabel('FVA fluxes','FontSize',18);
title('Comparion of VFFVA and FVA fluxes','fontsize',18);
xlim([-40 1000]);ylim([-40 1000])
legend('data points','y=x')
grid on

