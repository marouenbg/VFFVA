#!/bin/bash
#matlab='/usr/local/MATLAB/R2014b/bin/./matlab'
cd ../data/models
for model in Ecoli_core Ecoli_K12 P_Putida; 
do
	cd $model
	matlab -nodesktop -nosplash -r $model -logfile $model.out
	cd ..
done