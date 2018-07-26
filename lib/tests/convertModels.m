%Recon
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load Recon205_20150515Consistent;
convertProblem(modelConsistent,0,'Recon');
%%
%Ecoli
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load ecoli_core_model.mat;
convertProblem(model,0,'Ecoli_core');
%%
%Harvey
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load marouen.mat;
harvey = modelOrganAllCoupled;
convertProblem(harvey,1,'Harvey');
%%
%Harvey 1 mn
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load marouen.mat;
harvey=modelOrganAllCoupled;
indu = find(harvey.ub ~= 1000000 & harvey.ub~= 0 & harvey.ub~= -1000000);
indl = find(harvey.lb ~= 1000000 & harvey.lb~= 0 & harvey.lb~= -1000000);
harvey.lb(indl) = harvey.lb(indl)/24/60;
harvey.ub(indu) = harvey.ub(indu)/24/60;
convertProblem(harvey,1,'Harvey1mn');
%%
% Ematrix
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('Thiele et al. - E-matrix_LB_medium.mat');
convertProblem(model,0,'Ematrix');
%%
% Ematrix-coupled
load EMatrix_LPProblemtRNACoupled90.mat;
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
convertProblem(LPProblemtRNACoupled90,1,'EmatrixCoupled');
%%
% Putida
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('Pputida_model_glc_min.mat');
convertProblem(model,0,'Putida');
%%
%EColi k-12
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('iAF1260.mat');
convertProblem(modeliAF1260,0,'EcoliK12');
%%
%Ines's Harvey
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('2016_07_04_HarveyJoint_02_09_constraintHMDB_EUDiet_d.mat');
convertProblem(modelOrganAllCoupled,1,'Harvey17');
%%
%Fede 1
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('P:\Projects\veryfastFVA\models\microbiota_model_samp_SRS011452_modelHM_male_SimulationReady_02_09.mat')
modelHM.A=modelHM.S;
convertProblem(modelHM,1,'Male_11452');
%%
%Fede 2
cd('P:\Projects\veryfastFVA\models')
addpath(genpath('P:\Projects\veryfastFVA'))
load('P:\Projects\veryfastFVA\models\microbiota_model_samp_SRS013951_modelHM_male_SimulationReady_02_09.mat')
modelHM.A=modelHM.S;
convertProblem(modelHM,1,'Male_13951');


