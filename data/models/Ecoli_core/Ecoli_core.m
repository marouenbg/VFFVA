addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
addpath(genpath(['.' filesep '..']));
load ecoli_core_model;
runNmodels(model);
exit
