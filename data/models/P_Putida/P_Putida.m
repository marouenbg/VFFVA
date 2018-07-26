addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
addpath(genpath(['.' filesep '..']));
load Pputida_model_glc_min.mat;
runNmodels(model);
exit
