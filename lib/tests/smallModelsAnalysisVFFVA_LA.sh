#!/bin/bash
TIMEFORMAT=%R
echo -e "Threads,Ecoli_core,P_Putida,Ecoli_K12," > ../data/results/smallModelsTime_VFFVA_LA.csv
for nthreads in 2 4 8 16 32; do
	for run in `seq 1 3`; do
		TimeVec="$nthreads,"
		for model in Ecoli_core P_Putida Ecoli_K12; do
			exec 3>&1 4>&2
			foo=$( { time mpirun -np 1 --bind-to none -x OMP_NUM_THREADS=$nthreads ./../veryfastFVA ../data/models/$model/$model.mps 1>&3 2>&4; } 2>&1 )
			exec 3>&- 4>&-
			TimeVec+="$foo,"
		done
		echo -e "$TimeVec" >> ../data/results/smallModelsTime_VFFVA_LA.csv
	done
done

