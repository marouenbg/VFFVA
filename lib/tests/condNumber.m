load('ecoli_core_model.mat')
cond(full(model.S)) %8.3790e+17
load('Pputida_model_glc_min.mat')
cond(full(model.S))%6.1724e+32
load('iAF1260.mat')
cond(full(modeliAF1260.S)) %2.4103e+17
load('Recon205_20150515Consistent.mat')
cond(full(modelConsistent.S)) %2.5349e+17
load('Thiele et al. - E-matrix_LB_medium.mat')
cond(full(model.S))%6.5417e+21
load('EMatrix_LPProblemtRNACoupled90.mat')
cond(full(LPProblemtRNACoupled90.A))%3.9003e+21
WBM%3.2107e+23
condVec=[8.3790e+17,6.1724e+32,2.4103e+17,2.5349e+17,6.5417e+21,3.9003e+21,3.2107e+23];




%%
%ecoli
ecorespeed=[0.35,0.41,0.6]./[0.2,0.2,0.3]
%putida
putidaspeed=[0.53,0.51,0.53]./[0.4,0.4,0.4]
%ecoli k12
k12speed=[1.22,0.87,0.78]./[0.9,0.4,0.6]
%Recon2
VFFVA=readtable('largeModelsTime_VFFVA_LA.csv','Delimiter',',');
FVA=readtable('largeModelsTime_FFVA_LA.csv','Delimiter',',');
veryfast=zeros(3,5);
fast=zeros(3,5);
for k=1:3
    veryfast(k,:)=VFFVA.Recon2(k:3:15);
    fast(k,:)=FVA.Recon2(k:3:15);
end
reconspeed=(mean(fast(:,3:end))-20)./mean(veryfast(:,3:end))
%Ematrix
for k=1:3
    veryfast(k,:)=VFFVA.Ematrix(k:3:15);
    fast(k,:)=FVA.Ematrix(k:3:15);
end
ematspeed=(mean(fast(:,3:end))-20)./mean(veryfast(:,3:end))
%Ematrixc
VFFVA=readtable('EmatrixCoupledTime_VFFVA_LA.csv','Delimiter',',');
FVA=readtable('EmatrixCoupledTime_FFVA_LA.csv','Delimiter',',');
VFFVA16=readtable('EmatrixCoupledTime_VFFVA_LA_scheduele.csv','Delimiter',',');
%fetch running time and iterations
[schedueletime,iterationstime]=parseResultsFile();
for k=1:3
    veryfast(k,:)=VFFVA.Ematrix_coupled(k:3:15);
    fast(k,:)=FVA.Ematrix_coupled(k:3:15);
end
ematcspeed=(mean(fast(:,3:end))-20)./mean(veryfast(:,3:end))
%WBM
schedule=readtable('harvey1.csv','Delimiter',',');
wbmspeed=([2165 1611 861]-0.3)./(schedule.C100'/60)
%%
figure;
i=2
str={'Ecoli_core','P_putida','Ecoli_K12','Recon2','E_matrix','Ec_matrix','WBM'}
scatter(log10(condVec),[ecorespeed(i),putidaspeed(i),k12speed(i),reconspeed(i),...
    ematspeed(i),ematcspeed(i),wbmspeed(i)],'o', 'MarkerFaceColor', 'b')
hold on
textscatter(log10(condVec),[ecorespeed(i),putidaspeed(i),k12speed(i),reconspeed(i),...
    ematspeed(i),ematcspeed(i),wbmspeed(i)]+0.1,str)
ylim([0 3])
xlabel('log10(cond)')
ylabel('Speedup factor')
%%
[a,b]=corr(log10(condVec)',[ecorespeed(i),putidaspeed(i),k12speed(i),reconspeed(i),...
    ematspeed(i),ematcspeed(i),wbmspeed(i)]')