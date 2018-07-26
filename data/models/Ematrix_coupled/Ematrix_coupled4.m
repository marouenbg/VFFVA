    cpxControl.PARALLELMODE = 1;
    cpxControl.THREADS = 1;
    cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
load EMatrix_LPProblemtRNACoupled90.mat;
parpool(4)
[a,b]=fastFVA(LPProblemtRNACoupled90,90,'max','cplex',[],'A',cpxControl);
minMax=[a b];
save('MinMaxFFVA.mat','minMax');
exit