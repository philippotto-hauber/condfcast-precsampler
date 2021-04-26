#!/bin/bash
#SBATCH --job-name=simul
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=10:00:00
#SBATCH --output=simul.out
#SBATCH --error=simul.err
#SBATCH --partition=cluster

rm ./../../sim-precsampler/out/*

module load matlab/2020b

mcc -m simul.m -a ./CK1994 -a ./DK2002 -a ./../precsampler -a ./../functions

# DK 2002 smoother
for i in `seq 31 60`
do
	./simul $i &
done
wait

rm simul mccExcludedFiles.log requiredMCRProducts.txt readme.txt run_simul.sh
