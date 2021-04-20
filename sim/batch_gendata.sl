#!/bin/bash
#SBATCH --job-name=simul
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=300
#SBATCH --time=00:10:00
#SBATCH --output=simul.out
#SBATCH --error=simul.err
#SBATCH --partition=cluster

rm ./../../sim-precsampler/dgp/*

module load matlab/2020b
mcc -m generate_data.m -a ./../functions

for i in `seq 1 10`
do
	./generate_data $i &
done
wait

rm generate_data mccExcludedFiles.log requiredMCRProducts.txt readme.txt run_generate_data.sh