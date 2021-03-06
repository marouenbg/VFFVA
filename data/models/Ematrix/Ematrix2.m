    cpxControl.PARALLELMODE = 1;
    cpxControl.THREADS = 1;
    cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
load('Thiele et al. - E-matrix_LB_medium.mat')
parpool(2)
[a,b]=fastFVA(model,90,'max','cplex',[],'S',cpxControl);
minMax=[a b];
save('MinMaxFFVA.mat','minMax');
exit