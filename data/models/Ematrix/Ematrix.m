cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
parpool(2);
load('Thiele et al. - E-matrix_LB_medium.mat')
tic;[a,b]=fastFVA(model,90,'max','cplex',model.rxns,'S',cpxControl);toc;
exit