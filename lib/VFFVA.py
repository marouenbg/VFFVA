import os
import pandas as pd

def VFFVA(nCores, nThreads, model, scaling=0, memAff='none', schedule='dynamic', nChunk=50, optPerc=90):

    status = os.system('mpirun')
    if status != 0:
        raise(['MPI and/or CPLEX nont installed, please follow the install guide'...
               'or use the quick install script']);

    # Set schedule and chunk size parameters
    os.environ["OMP_SCHEDUELE"] = schedule+str(nChunk)

    # Call VFFVA
    status = os.system(
        'mpirun -np ' + str(nCores) + ' --bind-to ' + str(memAff) + ' -x OMP_NUM_THREADS=' + str(nThreads) +
         ' ./veryfastFVA ' + model + ' ' + str(optPerc) +  ' ' + str(scaling))

    # Fetch results
    resultFile = model[:-4] + 'output.csv'
    results = pd.read_csv(resultFile)
    minFlux = results.minFlux
    maxFlux = results.maxFlux

    return minFlux,maxFlux