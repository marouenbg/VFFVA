nCores=1;
nThreads=4;
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

%comapre to FVA from COBRA toolbox
[minFluxFVA,maxFluxFVA]=fluxVariability(ecoli);