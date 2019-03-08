function [minFlux,maxFlux]=VFFVA(nCores, nThreads, model, scaling, memAff, schedule, nChunk)
% performs Very Fast Flux Variability Analysis (VFFVA). VFFVA is a parallel implementation of FVA that
% allows dynamically assigning reactions to each worker depending on their computational load
% Guebila, Marouen Ben. "Dynamic load balancing enables large-scale flux variability analysis." bioRxiv (2018): 440701.
% 
% USAGE:
%
%    [minFlux,maxFlux]=VFFVA(nCores, nThreads, model, scaling, memAff, schedule, nChunk)
%
% INPUT:
%    nCores:           Number of non-shared memory cores/machines.
%    nThreads:         Number of shared memory threads in each core/machine.
%    model:            path to metabolic model in .mps format.
%
% OPTIONAL INPUTS:
%    scaling:          (Default = -1)
%    memAff:           none, core, or socket. (Default = none). This an OpenMPI parameter, more 
%                      information here: https://www.open-mpi.org/faq/?category=tuning#using-paffinity-v1.4.
%    schedule:         Dynamic, static, or guided. (Default = dynamic). This is an OpenMP parameter, more
%                      information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
%    nChunk:           Number of reactions in each chunk (Default = 50). This is an OpenMO parameter, more
%                      information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
%
% OUTPUTS:
%    minFlux:          (n,1) vector of minimal flux values for each reaction.
%    maxFlux:          (n,1) vector of maximal flux values for each reaction.
%
% .. Author:
%       - Marouen Ben Guebila

%(offer to convert model from .mat)

%Set optional parameters to defaults
if nargin<4
    scaling = 0;
end
if nargin<5
    memAff = 'none';
end
if nargin<6
   schedule='dynamic'; 
end
if nargin<7
    nChunk=50;
end

%Check if MPI is installed
[status,cmdout]=system('mpirun');
if status==127
    error(['MPI and/or CPLEX nont installed, please follow the install guide'...
    'or use the quick install script']);
end

%Set schedule and chunk size parameters
setenv('OMP_SCHEDUELE', [schedule ',' num2str(nChunk)])

%Set install folder of MPI
setenv('PATH', [getenv('PATH') [':' getenv(HOME) '/open-mpi/bin']])

%Call VFFVA
[status,cmdout]=system(['mpirun -np ' num2str(nCores) ' --bind-to ' num2str(memAff) ' -x OMP_NUM_THREADS=' num2str(nThreads)...
    ' ./veryfastFVA ' model ' ' num2str(scaling)]);

%Fetch results
resultFile=[model(1:end-4) 'output.csv'];
results=readtable(resultFile)
minFlux=results.minFlux; maxFlux=results.maxFlux;

%remove result file
delete(resultFile)

end
