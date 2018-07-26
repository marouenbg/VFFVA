cpxControl.PARALLELMODE = 1;
cpxControl.THREADS = 1;
cpxControl.AUXROOTTHREADS = 2;
addpath(genpath('/home/marouen.benguebila/utils/pCOBRA'));
parpool(32);
load Recon205_20150515Consistent;
tic;[a,b]=fastFVA(modelConsistent,90,'max','cplex',modelConsistent.rxns,'S',cpxControl);toc;
exit