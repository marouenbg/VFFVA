User manual of veryfastFVA (VFFVA).

#### Licence
CC-BY 4.0

Author: Marouen BEN GUEBILA 

Contact: marouen.b.guebila [AT] gmail.com

#### Description
VFFVA performs flux variability analysis (FVA) on genome-scale metabolic models.

#### Files and folders
Makefile

lib/veryfastFVA.c

lib/convertProblem.m

data/models

#### Input
VFFVA uses the `.mps` linear programming format.

You can use the provided MATLAB script `convertProblem.m` to convert MATLAB LP problems to `.mps` files

#### Installation:
1. Install a free academic version of IBM ILOG CPLEX.

	http://www-03.ibm.com/software/products/fr/ibmilogcpleoptistud

2. Check if you have openMP and MPI installed on your system. Usually, openMP comes by default with latest gcc distributions.

	For MPI, Install the distribution openMPI 1.10.3 

3. In the `Makefile`, change the CPLEXDIR variable to point to the installation directory of IBM ILOG CPLEX

4. make

5. Bind OpenMP threads to physical cores by setting the environment variable
`export OMP_BIND_PROC = TRUE`

6. Set the load balancing schedule with export `OMP_SCHEDULE=schedule,chunk`

	`schedule` can be either static, dynamic or guided

	`chunk` is an integer representing the minimal number of iterations processed per worker

	e.g., `export OMP_SCHEDULE=dynamic,50`

7. Run VFFVA like the following:

	`mpirun -np a --bind-to none -x OMP_NUM_THREADS=b ./veryfastFVA ./models/c.mps d e f`

	a: Number of non-memory sharing cores

	b: Number of memory-sharing threads

	c: model name, a selection of models is provided in model folder

	d: (optional) if not specified scaling (SCAIND) parameter is set to default

	if set to -1, scaling is deactivated
 
        e: (optional) percentage of objective function to consider

        f: (optional) .csv file containing the indices of the reactions to optimize.

	with openMPI 1.10.2 you might get error messages, launch the application as following:

	`mpirun -np  -mca btl openib --bind-to none -x OMP_NUM_THREADS= ./veryfastFVA ./models/.mps `

#### Output
Results are written to `modeloutput.csv` file with min and max flux for every reaction.

#### Benchmarking with MATLAB FFVA
0. MATLAB scripts of FFVA are provided in model directory, please change the parpool argument to the number of workers N that you would like to perform your test on. 

1. Run FFVA script like the following, in the model directory:

	`time matlab -nodesktop -nosplash -r  -logfile .out`

2. Run VFFVA script:

	`time mpirun -np  --bind-to none -x OMP_NUM_THREADS= ./veryfastFVA ./models/.mps `

3. Be aware that N has to be equal a*b to be able to compare in similar resource setting.

#### Advanced use

##### Changing load balancing schedules
1. You can choose the load balancing strategy through export `OMP_SCHEDULE=schedule, chunk`

    Static : predefined number of iterations per worker, each worker gets the same number of iterations

    Guided : each worker gets total_iterations/nworkers initially, then remaining_iterations/nworkers are distributed dynamically

    Dynamic: (default) each worker is updated by iterations of size chunk 

2. make

##### Asymmetrical resource assignment
0. In the call of VFFVA, `OMP_NUM_THREADS` parameter is a global variable that sets an equal number of threads in every core

1. If the case of asymmetrical resource assignment e.g. where in 2 nodes you have respectively 4 and 6 cores

	you can take out the `-x` option in the call of VFFVA and set the variable OMP_NUM_THREADS locally in every machine

	`export OMP_NUM_THREADS=4`

	`export OMP_NUM_THREADS=6`

2. Alternatively you can set the parameter programmatically in the main body of `veryfastFVA.c`, after the call of MPI through

	```c
    	if(id==0){
	        set_num_threads(6)
	    }elseif (id==1){
        	set_num_threads(4)
	    }
	```
3. make

#### Paper figures and tables
Regarding VFFVA, please set environment variables `OMP_PROC_BIND=FALSE` and export `OMP_SCHEDULE=dynamic,50` for the following section:

1. Table2: (Running times of small models: Ecoli_core, EcoliK12 and P_Putida).

	You can use run `outputSmallModelTable.m` in `lib` directory with the pre-computed result files.

	You can obtain your own benchmarking results through calling:
	- `smallModelsAnalysisFFVA_A.sh`: runs FFVA on small models and saves analysis time only.
	- `smallModelsAnalysisFFVA_LA.sh`: runs FFVA on small models and saves loading and analysis time.
	- `smallModelsAnalysisVFFVA_LA.sh`: runs VFFVA on small models and saves loading and analysis time.

2. Figure2: (Running times of large models: Recon2 and E_Matrix).

	You can run the first section of `statTest.m` in `lib` directory to plot the figure with pre-computed results.

	To recompute the benchamarking results, please run:
	- `largeModelsAnalysisFFVA_LA.sh`: runs FFVA on large models and saves loading and analysis time.
	- `largeModelsAnalysisVFFVA_LA.sh`: runs VFFVA on large models and saves loading and analysis time.

3. Figure3: (Running times of E_Matrix_coupled).

	In the following section, please set `OMP_PROC_BIND=TRUE`.
	You can run the second section of `statTest.m` in `lib` directory to plot the figure with pre-computed results.

	To recompute the benchmarking results, please run:
	- `EmatrixCoupledAnalysisFFVA_LA.sh`: runs FFVA on E_Matrix_coupled model and saves loading and analysis time.
	- `EmatrixCoupledAnalysisVFFVA_LA.sh`: runs VFFVA on E_Matrix_coupled model and saves loading and analysis time.

#### Important note
VFFVA is run by default on a suboptimal objective equal to 90% the optimal objective of the original problem, because with large models, numerical infeasibilities can occur with optimisation percentage
equal to 100%. You can change the optPerc variable to the desired value.
