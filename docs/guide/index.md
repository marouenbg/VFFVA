# Usage guide

The following provides the usage guide for both the C and MATLAB versions of VFFVA.

## C version

After installing the dependencies of `VFFVA`, you can build the binaries at the root of `lib` using `make`.

Then call `VFFVA` as follows:

`mpirun -np nCores --bind-to none -x OMP_NUM_THREADS=nThreads veryfastFVA model.mps OPTPERC SCAIND ex`

Replace the following variables with your own parameters:

+ nCores: the number of non-shared memory cores you wish to use for the analysis

+ nThreads: the number of shared memory threads within one core

+ model.mps: the metabolic model in `.mps` format. To convert a model in `.mat` format to `.mps`, you can use the provided converter `convertProblem.m`

+ OPTPERC: Optimization percentage of the objective value (0-100). The default is 90, where VFFVA will be computed with the objective value set to 90% of the optimal
objective.

+ SCAIND: (optional) corresponds to the scaling CPLEX parameter SCAIND and can take the values 0 (equilibration scaling: default), 1 (aggressive scaling), -1 (no scaling).
scaling is usually desactivated with tightly constrained metabolic model such as coupled models to avoid numerical instabilities and large solution times.

+ ex: .csv file containing indices of reactions to optimize e.g., 1,2,3,4,5 or check `rxns.csv` in the repository.

Example: `mpirun -np 2 --bind-to none -x OMP_NUM_THREADS=4 veryfastFVA ecoli_core.mps`

`VFFVA` will perform 2n Linear Programs (LP), where n is the number of reactions in a metabolic model, corresponding to
a minimization and a maximization in each dimension.

The ouput file is saved as `modeloutput.csv`, with model is the name of the metabolic model.

## MATLAB version

The MATLAB version VFFVA.m is a wrapper around the C version, which means that the previous installation steps of the C version have to be performed.

Then VFFVA.m can be called from MATLAB using the following function description:

```

 USAGE:

    [minFlux,maxFlux]=VFFVA(nCores, nThreads, model, scaling, memAff, schedule, nChunk, ex)

 INPUT:
    nCores:           Number of non-shared memory cores/machines.
    nThreads:         Number of shared memory threads in each core/machine.
    model:            .mps format: path to metabolic model in .mps format.
                      COBRA format: will be automatically formatted to .mps format. Make sure to add VFFVA folder to
                      your MATLAB path to access the conversion script.

 OPTIONAL INPUTS:
    scaling:          CPLEX parameter. It corresponds to SCAIND parameter (Default = 0).
                      -1: no scaling; 0: equilibration scaling; 1: more aggressive scaling.
                      more information here: https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.0/ilog.odms.cplex.help/CPLEX/Parameters/topics/ScaInd.html.
    optPerc:          Percentage of the optimal objective used in FVA. Float between 0 and 100. For example, when set to 90
		      FVA will be computed on 90% of the optimal objective. 
    memAff:           none, core, or socket. (Default = none). This an OpenMPI parameter, more 
                      information here: https://www.open-mpi.org/faq/?category=tuning#using-paffinity-v1.4.
    schedule:         Dynamic, static, or guided. (Default = dynamic). This is an OpenMP parameter, more
                      information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
    nChunk:           Number of reactions in each chunk (Default = 50). This is an OpenMO parameter, more
                      information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
    ex:               Indices of reactions to optimize. (Default, all reactions)

 OUTPUTS:
    minFlux:          (n,1) vector of minimal flux values for each reaction.
    maxFlux:          (n,1) vector of maximal flux values for each reaction.
```
## Python version

The Python version VFFVA.py is a wrapper around the C version, which means that the previous installation steps of the C version have to be performed.

Then VFFVA.py can be imported into a Python 3 script  using the following function description:

```

    USAGE:
    minFlux,maxFlux=VFFVA(nCores, nThreads, model, scaling, memAff, schedule, nChunk, optPerc, ex)

    :param nCores:   Number of non-shared memory cores/machines.
    :param nThreads: Number of shared memory threads in each core/machine.
    :param model:    .mps format: path to metabolic model in .mps format.
    :param scaling:  CPLEX parameter. It corresponds to SCAIND parameter (Default = 0).
                     -1: no scaling; 0: equilibration scaling; 1: more aggressive scaling.
                     more information here: https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.0/ilog.odms.cplex.help/CPLEX/Parameters/topics/ScaInd.html.
    :param memAff:   'none', 'core', or 'socket'. (Default = 'none'). This an OpenMPI parameter, more
                     information here: https://www.open-mpi.org/faq/?category=tuning#using-paffinity-v1.4.
    :param schedule: 'dynamic', 'static', or 'guided'. (Default = 'dynamic'). This is an OpenMP parameter, more
                     information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
    :param nChunk:   Number of reactions in each chunk (Default = 50). This is an OpenMP parameter, more
                     information here: https://software.intel.com/en-us/articles/openmp-loop-scheduling
    :param optPerc:  Percentage of the optimal objective used in FVA. Integer between 0 and 100. For example, when set to 90
                     FVA will be computed on 90% of the optimal objective.
    :param ex:       Indices of reactions to optimize as a numpy array.  (Default, all reactions)
    :return:
           minFlux:          (n,1) vector of minimal flux values for each reaction.
           maxFlux:          (n,1) vector of maximal flux values for each reaction.
```
