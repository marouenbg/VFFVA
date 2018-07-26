cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
parpool(32);
load EMatrix_LPProblemtRNACoupled90.mat;
tic;[a,b]=fastFVA(LPProblemtRNACoupled90,90,'max','cplex',LPProblemtRNACoupled90.rxns,'A',cpxControl);toc;
exit