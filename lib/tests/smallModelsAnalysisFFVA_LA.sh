#!/bin/bash
cd ../data/models
TIMEFORMAT=%R
echo -e "Threads,Ecoli_core,P_Putida,Ecoli_K12," > ../results/smallModelsTime_FFVA_LA.csv
for nthreads in 2 4 8 16 32; do
	for run in `seq 1 3`; do
		TimeVec="$nthreads,"
		for model in Ecoli_core P_Putida Ecoli_K12; do
			cd $model
			exec 3>&1 4>&2
			foo=$( { time matlab -nodesktop -nosplash -r $model$nthreads 1>&3 2>&4; } 2>&1 )
			exec 3>&- 4>&-
			TimeVec+="$foo,"
		    cd ..
		done
		echo -e "$TimeVec" >> ../results/smallModelsTime_FFVA_LA.csv
	done
done
