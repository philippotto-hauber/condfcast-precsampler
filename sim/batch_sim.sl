#!/bin/bash
#SBATCH --job-name=simul
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2000
#SBATCH --time=03:00:00
#SBATCH --output=simul.out
#SBATCH --error=simul.err
#SBATCH --partition=cluster

rm ./../../sim-precsampler/dgp/*
rm ./../../sim-precsampler/out/*

module load matlab/2020b
mcc -m simul.m -a ./CK1994 -a ./DK2002 -a ./../precsampler -a ./../functions

export OMP_NUM_THREADS=1

./simul

rm simul mccExcludedFiles.log requiredMCRProducts.txt readme.txt run_simul.sh
