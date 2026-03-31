/* --------------------------------------------------------------------------
 * File: veryfastFVA.c
 * Version 0.5.0
 * --------------------------------------------------------------------------
 * Licence CC BY 4.0 : Free to share and modify 
 * Author : Marouen BEN GUEBILA - marouen.benguebila@uni.lu
 * --------------------------------------------------------------------------
 */
/* veryfastFVA.c - A hybrid Open MP/MPI parallel optimization of fastFVA
   Usage
      veryfastFVA <datafile>   
      <datafile> : .mps file containing LP problem
   Solver backends: CPLEX (default) or GLPK (compile with -DUSE_GLPK)
 */
/*open mp declaration*/
#include <omp.h>
#include "mpi.h"

#ifdef USE_GLPK
/* GLPK declaration */
#include <glpk.h>
#else
/* ILOG Cplex declaration*/
#include <ilcplex/cplex.h>
#endif

/* Bring in the declarations for the string and I/O functions */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
/*Forward declaration*/
static void
   free_and_null     (char **ptr),
   usage             (char *progname);

#ifdef USE_GLPK

/* GLPK is not thread-safe: its internal memory allocator uses global state.
   Concurrent glp_simplex calls from OpenMP threads corrupt memory.
   We disable OpenMP for GLPK and rely on MPI-only parallelism. */
void fva(glp_prob *lp, double objval, int n, int scaling, double *minFlux, double *maxFlux, int rank, int numprocs, int *rxns){
	int i,j,ret,solst;
	int iters = 0;
	double wTime = omp_get_wtime();
	
	if(rank==0){
		printf("\nNumber of threads = 1 (GLPK: MPI-only), Number of CPUs = %d\n\n",numprocs);
	}
	
	/* Create a single working copy of the LP */
	glp_prob *lpi = glp_create_prob();
	glp_copy_prob(lpi, lp, GLP_OFF);
	
	glp_smcp parm;
	glp_init_smcp(&parm);
	parm.msg_lev = GLP_MSG_OFF;
	parm.meth = GLP_DUALP;
	
	for(j=-1;j<2;j+=2){
		for(i=rank*n/numprocs;i<(rank+1)*n/numprocs;i++){
			/* GLPK columns are 1-based: rxns[i] is 0-based, so +1 */
			int col = rxns[i] + 1;
			glp_set_obj_dir(lpi, (j==-1) ? GLP_MAX : GLP_MIN);
			iters++;
			glp_set_obj_coef(lpi, col, 1.0);
			ret = glp_simplex(lpi, &parm);
			if (ret != 0) {
				fprintf(stderr, "Warning: glp_simplex failed (ret=%d) on rxn %d, direction %s\n",
					ret, rxns[i], (j==-1)?"max":"min");
			}
			solst = glp_get_status(lpi);
			if (solst != GLP_OPT) {
				fprintf(stderr, "Warning: non-optimal status %d on rxn %d, direction %s\n",
					solst, rxns[i], (j==-1)?"max":"min");
			}
			objval = glp_get_obj_val(lpi);
			if(j==-1){
				maxFlux[i] = objval;
			}else{
				minFlux[i] = objval;
			}
			glp_set_obj_coef(lpi, col, 0.0);
		}
	}
	
	wTime = omp_get_wtime() - wTime;
	printf("Process %d/%d did %d iterations in %f s\n",rank+1,numprocs,iters,wTime);
	glp_delete_prob(lpi);
}

#else /* CPLEX */

void fva(CPXLPptr lp, double objval, int n, int scaling, double *minFlux,double *maxFlux, int rank, int numprocs, int *rxns){
	/* The actual Open MP FVA called with CPLEX env, CPLEX LP
	the optimal LP solution and n the number of rows
	*/
	int status;
	int cnt = 1;//number of bounds to be changed
	double zero=0, one=1;//optimisation percentage
	int i,j,tid,nthreads,solstat;
	
	/*optimisation loop Max:j=-1 Min:j=+1*/
	#pragma omp parallel private(tid,i,j,solstat,status,objval) shared(minFlux,maxFlux)
		{
			int iters = 0;
			double wTime = omp_get_wtime();
			tid=omp_get_thread_num();
			if(tid==0){
				nthreads=omp_get_num_threads();
				if(rank==0){
					printf("\nNumber of threads = %d, Number of CPUs = %d\n\n",nthreads,numprocs);
				}
			}
			CPXENVptr     env = NULL;
			CPXLPptr      lpi = NULL;
			env = CPXopenCPLEX (&status);//open cplex instance for every thread
			//status = CPXsetintparam (env, CPX_PARAM_PREIND, CPX_OFF);//deactivate presolving
			lpi = CPXcloneprob(env,lp, &status);//clone problem for every thread
			
			/*set solver parameters*/
			status = CPXsetintparam (env, CPX_PARAM_PARALLELMODE, 1);
			status = CPXsetintparam (env, CPX_PARAM_THREADS, 1);
			status = CPXsetintparam (env, CPX_PARAM_AUXROOTTHREADS, 2);
			
			if (scaling){
				/*Change of scaling parameter*/
				status = CPXsetintparam (env, CPX_PARAM_SCAIND, -1);//1034 is index scaling parameter
			}
			
			for(j=-1;j<2;j+=2){
				#pragma omp for schedule(runtime) nowait
				for(i=rank*n/numprocs;i<(rank+1)*n/numprocs;i++){
					status= CPXchgobjsen (env, lpi, j);
					iters++;
					status = CPXchgobj (env, lpi, cnt, &rxns[i], &one);//change obj index
					status = CPXlpopt (env, lpi);//solve LP
					status = CPXgetobjval(env, lpi, &objval);
					solstat = CPXgetstat(env, lpi);
					//save results
					if(j==-1){//save results
						maxFlux[i]   =objval;
						//maxsolStat[i]=solstat;
					}else{
						minFlux[i]   =objval;
						//minsolStat[i]=solstat;
					}
					status = CPXchgobj (env, lpi, cnt, &rxns[i], &zero);//set obj index to zero for next optim
				}	
			}	
			
			wTime = omp_get_wtime() - wTime;
			printf("Thread %d/%d of process %d/%d did %d iterations in %f s\n",omp_get_thread_num(),omp_get_num_threads(),rank+1,numprocs,iters,wTime);
			
			/* Free per-thread CPLEX resources */
			if ( lpi != NULL ) {
				CPXfreeprob(env, &lpi);
				lpi = NULL;
			}
			if ( env != NULL ) {
				CPXcloseCPLEX(&env);
				env = NULL;
			}
		}
}

#endif /* USE_GLPK */

int main (int argc, char **argv){
	int status = 0;
	double elapsedTime;
	struct timespec now, tmstart;
	double *cost     = NULL;
	double *lb       = NULL;
	double *ub       = NULL;
	double objval, robjval, zero=0;
	int    solstat,nAll;
	int cnt=1;
#ifdef USE_GLPK
	glp_prob *lp = NULL;
#else
	CPXENVptr     env = NULL;//CPLEX environment
	CPXLPptr      lp = NULL;//LP problem
#endif
	int           curpreind,i,j,m,n,scaling=0;
	const double tol = 1.0e-6;//tolerance for the optimisation problem
	double optPerc = 0.9, *obj = NULL;
	int objInd;
	char low='L';
	double *minFlux = NULL, *maxFlux = NULL;
	double *globalminFlux = NULL, *globalmaxFlux = NULL;
	int numprocs, rank, namelen;
	char processor_name[MPI_MAX_PROCESSOR_NAME];
	FILE *fp;
	char modelName[512];
	char outputPath[512];
    int *rxns = NULL;
	
	/*Initialize MPI*/
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Get_processor_name(processor_name, &namelen);	
	
	/*Check arg number*/
	if (rank==0){
		if(( argc == 2 ) || ( argc == 3 ) || (argc == 4) || (argc == 5)){
			printf("\nThe model supplied is %s\n", argv[1]);
			strncpy(modelName,argv[1],sizeof(modelName)-1);
			modelName[sizeof(modelName)-1]='\0';
		}else if( argc > 5) {
			printf("Too many arguments supplied.\n");
			goto TERMINATE;
		}else {
			printf("One argument expected.\n");
			goto TERMINATE;
		}
    	}
	
#ifdef USE_GLPK
	/* Suppress terminal output from GLPK */
	glp_term_out(GLP_OFF);
	
	/* Create and read the problem */
	lp = glp_create_prob();
	if ( lp == NULL ) {
		fprintf (stderr, "Failed to create LP.\n");
		goto TERMINATE;
	}
	status = glp_read_mps(lp, GLP_MPS_FILE, NULL, argv[1]);
	if ( status ) {
		fprintf (stderr, "Failed to read MPS file.\n");
		goto TERMINATE;
	}
	
	/*Sense of optimization - maximize*/
	glp_set_obj_dir(lp, GLP_MAX);
	
	/*Scaling parameter*/
	if ( argc >= 4 ) {
		if (atoi(argv[3])==-1){
			scaling = 1;
			if(rank==0) printf("Scaling disabled\n");
		}
	}
	
	/*Read OptPercentage*/
	if (argc > 2) {
		optPerc=atoi(argv[2])/100.0;
	}
	
	/* Optimize the problem and obtain solution. */
	clock_gettime(CLOCK_REALTIME, &tmstart);
	{
		glp_smcp parm;
		glp_init_smcp(&parm);
		parm.msg_lev = GLP_MSG_OFF;
		if (scaling) parm.presolve = GLP_OFF;
		status = glp_simplex(lp, &parm);
	}
	if ( status ) {
		fprintf (stderr, "Failed to optimize LP.\n");
		goto TERMINATE;
	}
	
	/*Problem size */
	m = glp_get_num_rows(lp);
	nAll = glp_get_num_cols(lp);
	
	/*Rxns to optimize */
	if ( argc==5 ){
		FILE *fpp;
		int num, count = 0;
		
		fpp = fopen(argv[4], "r");
		if (fpp == NULL) {
			printf("Error opening file.\n");
			return 1;
		}
		while (fscanf(fpp, "%d", &num) == 1) {
			count++;
		}
		
		rxns = (int *) malloc(count * sizeof(int));
		fseek(fpp, 0, SEEK_SET);
		
		for (int i = 0; i < count; i++) {
			fscanf(fpp, "%d", &rxns[i]);
		}
		n = count;
		fclose(fpp);
	}else{
		n = nAll;
		rxns = (int*)calloc(n, sizeof(int));
		for (int i=0; i < n; i++){
			rxns[i]=i;
		}
	}
	
	/*Get objective value*/
	objval = glp_get_obj_val(lp);
	solstat = glp_get_status(lp);
	robjval = floor(objval/tol)*tol*optPerc;
	
	/*Look for the index of the objective (0-based internally)*/
	objInd = -1;
	for(i=0;i<nAll;i++){
		if(glp_get_obj_coef(lp, i+1) != 0.0){  /* GLPK is 1-based */
			objInd = i;
		}		
	}
	
	/* Write the output to the screen. */
	if(rank==0){
		printf ("Solution value  = %f\n", objval);
		printf ("Solution status = %d\n", solstat);
		printf ("Solving %d reactions !\n", n);
		printf("Objective index is %d\n",objInd);
		
		if (optPerc*100 != -1) {
			printf("\nRunning biased FVA- setting lower bound of objective to %.f%% of optimal value!\n",optPerc*100);
			printf("Rounded solution at %.f%% is %f\n",optPerc*100,robjval);
		} else {
			printf("\nRunning regular FVA- keeping objective bounds as found in model!");
		}
	}
	
	/* Set lower bound of objective reaction to fraction of optimum */
	if (optPerc*100 != -1) {
		double curUb = glp_get_col_ub(lp, objInd+1);
		glp_set_col_bnds(lp, objInd+1, GLP_DB, robjval, curUb);
	}
	
	/*Set the objective coefficient to zero*/
	glp_set_obj_coef(lp, objInd+1, 0.0);

#else /* CPLEX */

	/* Initialize the CPLEX environment */
	env = CPXopenCPLEX (&status);
	if ( env == NULL ) {
		char  errmsg[CPXMESSAGEBUFSIZE];
		fprintf (stderr, "Could not open CPLEX environment.\n");
		CPXgeterrorstring (env, status, errmsg);
		fprintf (stderr, "%s", errmsg);
		goto TERMINATE;
	}
	
	/* Turn off output to the screen */
	status = CPXsetintparam (env, CPXPARAM_ScreenOutput, CPX_OFF);
	if ( status ) {
      		fprintf (stderr, 
               	"Failure to turn on screen indicator, error %d.\n", status);
      		goto TERMINATE;
	}
	
	/* Create the problem. */
	lp = CPXcreateprob (env, &status, "Problem");
	if ( lp == NULL ) {
		fprintf (stderr, "Failed to create LP.\n");
		goto TERMINATE;
	}
	
	/*Read problem */
	status = CPXreadcopyprob (env, lp, argv[1], NULL);
   
	/*Change problem type*/
	status = CPXchgprobtype(env,lp,CPXPROB_LP);
   
	/*Sense of optimization*/
	status=CPXchgobjsen (env, lp, -1);
	
	/*Set solver parameters*/
	status = CPXsetintparam (env, CPX_PARAM_PARALLELMODE, 1);
	status = CPXsetintparam (env, CPX_PARAM_THREADS, 1);
	status = CPXsetintparam (env, CPX_PARAM_AUXROOTTHREADS, 2);
	
	/*Scaling parameter if coupled model*/
	if ( argc >= 4 ) {
		if (atoi(argv[3])==-1){
		/*Change of scaling parameter*/
		scaling = 1;
		status = CPXsetintparam (env, CPX_PARAM_SCAIND, -1);//1034 is index scaling parameter
		status = CPXgetintparam (env, CPX_PARAM_SCAIND, &curpreind);
		printf("SCAIND parameter is %d\n",curpreind);
		}
	}

	/*Read OptPercentage*/
	if (argc > 2) {
		optPerc=atoi(argv[2])/100.0;
	}

	/* Optimize the problem and obtain solution. */
	clock_gettime(CLOCK_REALTIME, &tmstart);
	status = CPXlpopt (env, lp);
	if ( status ) {
		fprintf (stderr, "Failed to optimize LP.\n");
		goto TERMINATE;
	}
	
	/*Problem size */
	m = CPXgetnumrows (env, lp);
	nAll = CPXgetnumcols (env, lp);
        /*Rxns to optimize */
        if ( argc==5 ){
            int readFile=1;
            if ( readFile==1 ) {
                FILE *fpp;
				int num, count = 0;
				
				fpp = fopen(argv[4], "r");
				if (fpp == NULL) {
					printf("Error opening file.\n");
					return 1;
				}
				while (fscanf(fpp, "%d", &num) == 1) {
					count++;
				}
			
				rxns = (int *) malloc(count * sizeof(int));
				fseek(fpp, 0, SEEK_SET);
				
				for (int i = 0; i < count; i++) {
					fscanf(fpp, "%d", &rxns[i]);
				}
				n = count;
				
				fclose(fpp);
            }
        }else{
            n = nAll;
            rxns = (int*)calloc(n, sizeof(int));
            for (int i=0; i < n; i++){
               rxns[i]=i;
            }
        }

	/*Round objective value*/
	status = CPXgetobjval(env, lp, &objval);
	solstat = CPXgetstat(env, lp);
	if ( status ) {
      		fprintf (stderr, "Failed to obtain solution.\n");
      		goto TERMINATE;
	}
	robjval = floor(objval/tol)*tol*optPerc;//because max
	
	/*Look for the index of the objective*/
	obj =(double*)calloc(nAll, sizeof(double));
	status = CPXgetobj (env, lp, obj, 0, nAll-1);
	for(i=0;i<nAll;i++){
		if(obj[i]){
			objInd=i;
		}		
	}
	
	/* Write the output to the screen. */
	if(rank==0){
		printf ("Solution value  = %f\n", objval);
		printf ("Solution status = %d\n", solstat);
		printf ("Solving %d reactions !\n", n);
		printf("Objective index is %d\n",objInd);
		
		if (optPerc*100 != -1) {
			printf("\nRunning biased FVA- setting lower bound of objective to %.f%% of optimal value!\n",optPerc*100);
			printf("Rounded solution at %.f%% is %f\n",optPerc*100,robjval);
		} else {
			printf("\nRunning regular FVA- keeping objective bounds as found in model!");
		}
	}

	if (optPerc*100 != -1) {
		status = CPXchgbds (env, lp, cnt, &objInd, &low, &robjval);
	}
	
	/*Set the objective coefficient to zero*/
	status = CPXchgobj (env, lp, cnt, &objInd, &zero);
	
#endif /* USE_GLPK - end of solver-specific setup */

	/*Dynamically allocate result vector*/
	minFlux = (double*)calloc(n, sizeof(double));
	maxFlux = (double*)calloc(n, sizeof(double));
	globalminFlux = (double*)calloc(n, sizeof(double));
	globalmaxFlux = (double*)calloc(n, sizeof(double));
    
	/*Disable dynamic teams*/
	omp_set_dynamic(0); 
	
	/* FVA */
	fva(lp, robjval, n, scaling, minFlux, maxFlux, rank, numprocs, rxns);
	
	/*Reduce results*/
	MPI_Barrier(MPI_COMM_WORLD);
	MPI_Allreduce(minFlux, globalminFlux, n, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
	MPI_Allreduce(maxFlux, globalmaxFlux, n, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);

	
	/*Save to csv file*/
        if(rank==0){
            /* Build output path: strip .mps extension, append output.csv */
            {
                size_t len = strlen(modelName);
                if (len >= 4 && strcmp(&modelName[len-4], ".mps") == 0)
                    modelName[len-4] = '\0';
                snprintf(outputPath, sizeof(outputPath), "%soutput.csv", modelName);
            }
            fp=fopen(outputPath,"w+");
	    fprintf(fp,"minFlux,maxFlux\n");
		for(i=0;i<n;i++){
			fprintf(fp,"%f,%f\n",globalminFlux[i],globalmaxFlux[i]);
		}
            fclose(fp);
	}
	
	/*Finalize*/
	clock_gettime(CLOCK_REALTIME, &now);
	elapsedTime = (double)((now.tv_sec+now.tv_nsec*1e-9) - (double)(tmstart.tv_sec+tmstart.tv_nsec*1e-9));
	if (rank==0){
		printf("FVA done in %.5f seconds.\n", elapsedTime);
	}
	MPI_Finalize();
	
TERMINATE:
#ifdef USE_GLPK
	if ( lp != NULL ) {
		glp_delete_prob(lp);
		lp = NULL;
	}
#else
   	/* Free up the problem as allocated by CPXcreateprob, if necessary */
	if ( lp != NULL ) {
		status = CPXfreeprob (env, &lp);
		if ( status ) {
			fprintf (stderr, "CPXfreeprob failed, error code %d.\n", status);
		}
	}
	
	/* Free up the CPLEX environment, if necessary */
	if ( env != NULL ) {
		status = CPXcloseCPLEX (&env);
		if ( status > 0 ) {
			char  errmsg[CPXMESSAGEBUFSIZE];
			fprintf (stderr, "Could not close CPLEX environment.\n");
			CPXgeterrorstring (env, status, errmsg);
			fprintf (stderr, "%s", errmsg);
		}
	}
#endif
	free_and_null ((char **) &cost);
	free_and_null ((char **) &lb);
	free_and_null ((char **) &ub);
	free_and_null ((char **) &obj);
	free_and_null ((char **) &rxns);
	free_and_null ((char **) &minFlux);
	free_and_null ((char **) &maxFlux);
	free_and_null ((char **) &globalminFlux);
	free_and_null ((char **) &globalmaxFlux);
	return (status);
}  /* END main */

/* Function to free up the pointer *ptr, and sets *ptr to NULL */
static void free_and_null (char **ptr){
   if ( *ptr != NULL ) {
      free (*ptr);
      *ptr = NULL;
   }
} /* END free_and_null */  

static void usage (char *progname){
   fprintf (stderr,"Usage: %s -X <datafile>\n", progname);
   fprintf (stderr,"   where X is one of the following options: \n");
   fprintf (stderr,"      r          generate problem by row\n");
   fprintf (stderr,"      c          generate problem by column\n");
   fprintf (stderr," Exiting...\n");
} /* END usage */
