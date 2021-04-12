#!/bin/bash
#SBATCH --job-name=sim
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2000
#SBATCH --time=03:00:00
#SBATCH --output=sim.out
#SBATCH --error=sim.err
#SBATCH --partition=cluster

export OMP_NUM_THREADS=1

rm ./../../sim-precsampler/dgp/*
rm ./../../sim-precsampler/out/*

module load matlab/2020b

./batch_sim
