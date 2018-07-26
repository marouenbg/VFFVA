    cpxControl.PARALLELMODE = 1;
    cpxControl.THREADS = 1;
    cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
load iAF1260;
parpool(32)
[a,b]=fastFVA(modeliAF1260,90,'max','cplex',[],'S',cpxControl);
minMax=[a b];
save('MinMaxFFVA.mat','minMax');
exit