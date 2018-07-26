#!/bin/bash
TIMEFORMAT=%R
echo -e "Schedule,matlab,C50,C100,C500,C1000,guided,static,julia," >> ../data/results/HarveyTime_VFFVA_LA_scheduele.csv
for nthreads in 32; do
	TimeVec="$nthreads,"
	for scheduele in matlab "dynamic,50" "dynamic,100" "dynamic,500" "dynamic,1000" "guided" "static" julia; do
		for model in Harvey ; do
			if [ "$scheduele" == "matlab" ];
			then
				cd ../data/models/$model/FFVA
				exec 3>&1 4>&2
				foo=$( { time matlab -nodesktop -nosplash -r $model$nthreads 1>&3 2>&4; } 2>&1 )
				exec 3>&- 4>&-
				cd ../../../../lib
			elif [ "$scheduele" == "julia" ];
			then
				cd ../data/models/$model/distributedFBA
				exec 3>&1 4>&2
				foo=$( { time julia $model$nthreads.jl 1>&3 2>&4; } 2>&1 )
				exec 3>&- 4>&-
				cd ../../../../lib
			else
				export OMP_SCHEDULE=$scheduele
				exec 3>&1 4>&2
				foo=$( { time mpirun -np 1 --bind-to none -x OMP_NUM_THREADS=$nthreads ../veryfastFVA ../data/models/$model/$model.mps -1 1>../data/models/$model/$scheduele$nthreads.out 2>&4; } 2>&1 )
				exec 3>&- 4>&-
			fi
			TimeVec+="$foo,"
		done
	done
	echo -e "$TimeVec" >> ../data/results/HarveyTime_VFFVA_LA_scheduele.csv
done

