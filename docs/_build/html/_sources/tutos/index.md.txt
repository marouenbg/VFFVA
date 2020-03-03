# Tutorials

First, make sure that VFFVA.m in MATLAB is correctly installed.

## Comparison of the results of FVA and VFFVA

In this tutorial, we would like to compare the consistency of the results between the COBRA Toolbox FVA function
and VFFVA.

+ Install the COBRA Toolbox through entering in your command prompt

```
git clone https://github.com/opencobra/cobratoolbox.git
```

+ Then launch MATLAB and add COBRA Toolbox to the path

```
addpath(genpath(\path\to\cobratoolbox))
```

+ Initiate the COBRA Toolbox

```
initCobraToolbox
```

+ Change the solver to IBM CPLEX

```
changeCobraSolver('ibm_cplex')
```

+ Run FVA on Ecoli core model

```
load ecoli_core_model.mat
ecoli=model;
optPercentage=90;
[minFluxFVA,maxFluxFVA]=fluxVariability(ecoli, optPercentage);
```

+ Run VFFVA on Ecoli core model

```
nCores=1;
nThreads=4;
load ecoli_core_model.mat
ecoli=model;
[minFluxVFFVA,maxFluxVFFVA]=VFFVA(nCores, nThreads, ecoli);
```

+ Compare the results

```
%Using a log-log scale 
figure;
loglog(abs([minFluxVFFVA;maxFluxVFFVA]),abs([minFluxFVA;maxFluxFVA]),'o')
hold on;
loglog([0.1 1000],[0.1 1000])
```

As we can see the results lie perfectly on the identity line.
![](images/VFFVAbenchmark.png)

We can further check the largest difference in precision between the two results.
Since we are using the same solver, the results are nearly identical.

```
max(abs([minFluxVFFVA;maxFluxVFFVA]-[minFluxFVA;maxFluxFVA]))

ans =

   4.9314e-07
```
