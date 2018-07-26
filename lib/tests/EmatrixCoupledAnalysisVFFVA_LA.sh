#!/bin/bash
TIMEFORMAT=%R
echo -e "Threads,Ematrix_coupled," > ../data/results/EmatrixCoupledTime_VFFVA_LA.csv
for nthreads in 2 4 8 16 32; do
	for run in `seq 1 3`; do
		TimeVec="$nthreads,"
		for model in Ematrix_coupled ; do
			export OMP_SCHEDULE=dynamic,50
			exec 3>&1 4>&2
			foo=$( { time mpirun -np 1 --bind-to none -x OMP_NUM_THREADS=$nthreads ./../veryfastFVA ../data/models/$model/$model.mps 1>&3 2>&4; } 2>&1 )
			exec 3>&- 4>&-
			TimeVec+="$foo,"
		done
		echo -e "$TimeVec" >> ../data/results/EmatrixCoupledTime_VFFVA_LA.csv
	done
done

echo -e "Schedule,Ematrix_coupled," > ../data/results/EmatrixCoupledTime_VFFVA_LA_scheduele.csv
for nthreads in 16; do
	for scheduele in "static" "dynamic,50" "guided"; do
		for model in Ematrix_coupled ; do
			export OMP_SCHEDULE=$scheduele
			exec 3>&1 4>&2
			foo=$( { time mpirun -np 1 --bind-to none -x OMP_NUM_THREADS=$nthreads ./../veryfastFVA ../data/models/$model/$model.mps 1>../data/models/$model/$scheduele.out 2>&4; } 2>&1 )
			exec 3>&- 4>&-
			if [ "$scheduele" == "dynamic,50" ];
			then
				scheduele="dynamic"
			fi
			TimeVec="$scheduele,"
			TimeVec+="$foo,"
		done
		echo -e "$TimeVec" >> ../data/results/EmatrixCoupledTime_VFFVA_LA_scheduele.csv
	done
done

