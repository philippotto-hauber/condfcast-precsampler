#!/bin/bash
#SBATCH --job-name=simul
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=03:00:00
#SBATCH --output=simul.out
#SBATCH --error=simul.err
#SBATCH --partition=cluster

rm ./../../sim-precsampler/out/*
rm ./../../sim-precsampler/dgp/*

module load matlab/2020b
mcc -m generate_data.m -a ./../functions

for i in `seq 1 10`
do
	./generate_data $i &
done
wait

rm generate_data mccExcludedFiles.log requiredMCRProducts.txt readme.txt run_generate_data.sh

mcc -m simul.m -a ./CK1994 -a ./DK2002 -a ./../precsampler -a ./../functions

for i in `seq 1 30`
do
	./simul $i &
done
wait

rm simul mccExcludedFiles.log requiredMCRProducts.txt readme.txt run_simul.sh
