/* --------------------------------------------------------------------------
 * File: veryfastFVA.c
 * Version 1.0
 * --------------------------------------------------------------------------
 * Licence CC BY 4.0 : Free to share and modify 
 * Author : Marouen BEN GUEBILA - marouen.benguebila@uni.lu
 * --------------------------------------------------------------------------
 */
/* veryfastFVA.c - A hybrid Open MP/MPI parallel optimization of fastFVA
   Usage
      veryfastFVA <datafile>   
      <datafile> : .mps file containing LP problem
 */
/*open mp declaration*/
#include <omp.h>
#include "mpi.h"
 
/* ILOG Cplex declaration*/
#include <ilcplex/cplex.h>
/* Bring in the declarations for the string functions */
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
/*Forward declaration*/
static void
   free_and_null     (char **ptr),
   usage             (char *progname);
   
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
					printf("Number of threads = %d, Number of CPUs = %d\n\n",nthreads,numprocs);
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
					solstat = (double)CPXgetstat(env, lpi);
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
		}
}

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
	CPXENVptr     env = NULL;//CPLEX environment
	CPXLPptr      lp = NULL;//LP problem
	int           curpreind,i,j,m,n,scaling=0;
	const double tol = 1.0e-6;//tolerance for the optimisation problem
	double optPerc = 0.9, *obj;
	int objInd;
	char low='L';
	double *minFlux, *maxFlux;
	double *globalminFlux, *globalmaxFlux;
	int numprocs, rank, namelen;
	char processor_name[MPI_MAX_PROCESSOR_NAME];
	FILE *fp;
	char fileName[100] = "output.csv";
	char modelName[100];
        int *rxns;
	
	/*Initialize MPI*/
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &rank);
	MPI_Get_processor_name(processor_name, &namelen);	
	
	/*Check arg number*/
	if (rank==0){
		if(( argc == 2 ) | ( argc == 3 ) | (argc == 4) | (argc == 5)){
			printf("\nThe model supplied is %s\n", argv[1]);
			strcpy(modelName,argv[1]);
		}else if( argc > 5) {
			printf("Too many arguments supplied.\n");
			goto TERMINATE;
		}else {
			printf("One argument expected.\n");
			goto TERMINATE;
		}
    	}
	
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
	
	/* Turn on data checking */
	/*status = CPXsetintparam (env, CPXPARAM_Read_DataCheck, CPX_ON);
	if ( status ) {
		fprintf (stderr, "Failure to turn on data checking, error %d.\n", status);
		goto TERMINATE;
	}*/
	
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
	if ( argc == 4 ) {
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
            rxns = (int*)calloc(nAll, sizeof(int));//realloc this
            int readFile=1;
            if ( readFile==1 ) {
                FILE *fpp;
                fpp = fopen(argv[4], "r");
                if (fpp == NULL) {
                    fprintf(stderr, "Error reading file\n");
                     return 1;
                 }
                 char buf[2048];//realloc this
                 n = 0;
                 while (fgets(buf, 1024, fpp)) {

                     char *field = strtok(buf, ",");
                     while (field) {

                        //printf("%s\n", field);
                        rxns[n] = atoi(field);
                        field   = strtok(NULL, ",");

                        n++;
                    }
                }
	        fclose(fpp);
            }
            rxns = (int *) realloc(rxns, n*sizeof(int));
        }else{
            n = nAll;
            rxns = (int*)calloc(n, sizeof(int));
            for (int i=0; i < n; i++){
               rxns[i]=i;
            }
        }

	/*Round objective value*/
	status = CPXgetobjval(env, lp, &objval);
	solstat = (double)CPXgetstat(env, lp);
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
		printf("Rounded solution at %.f%%  is %f\n",optPerc*100,robjval);
		printf ("Solving %d reactions !\n", n);
		printf("Objective index is %d\n",objInd);
	}
	
	/*Set the lower bound of objective to its max value (biased FVA)*/
	status = CPXchgbds (env, lp, cnt, &objInd, &low, &robjval);
	
	/*Set the objective coefficient to zero*/
	status = CPXchgobj (env, lp, cnt, &objInd, &zero);
	
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

	
	/* Print results*/
	/*if(rank==0){
		for(i=0;i<n;i++){//print results and status 
			printf("Min %d is %.2f status is %.1f \n",i,globalminFlux[i],globalminsolStat[i]);
			printf("Max %d is %.2f status is %.1f \n",i,globalmaxFlux[i],globalmaxsolStat[i]);
		}
	}*/
	
	/*Save to csv file*/
        if(rank==0){
            for(i=strlen(modelName)-4;i<strlen(modelName);i++){
	  	    modelName[i]=0;
	    }
	    strcat(modelName, fileName);
            fp=fopen(modelName,"w+");
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
	free_and_null ((char **) &cost);
	free_and_null ((char **) &lb);
	free_and_null ((char **) &ub);
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
