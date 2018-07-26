cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;
cpxControl.SCAIND=-1;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
parpool(16);
cd ..
load marouen;
tic;[a,b]=fastFVA(modelOrganAllCoupled,90,'max','cplex',[],'A',cpxControl);
minMax=[a b];
save('MinMaxFFVA.mat','minMax');
toc;
exit