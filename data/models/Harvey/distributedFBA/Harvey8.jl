nWorkers = 8;

solverName = :CPLEX;

include("/home/marouen.benguebila/utils/COBRA.jl/src/connect.jl");

workersPool, nWorkers = createPool(nWorkers);

using COBRA;

solver = changeCobraSolver(solverName,((:CPX_PARAM_PARALLELMODE,1),(:CPX_PARAM_THREADS,1),(:CPX_PARAM_AUXROOTTHREADS,2),(:CPX_PARAM_SCAIND,-1),(:CPX_PARAM_SCRIND,0)));

model=loadModel("/home/marouen.benguebila/P:/Projects/veryfastFVA/data/models/Harvey/marouenmod.mat");

minFlux, maxFlux, optSol, fbaSol, fvamin, fvamax, statussolmin, statussolmax = distributedFBA(model, solver, nWorkers=nWorkers, optPercentage=90.0,objective="max",onlyFluxes=true);

saveDistributedFBA("results.mat", ["minFlux", "maxFlux"]);

exit(1)
