#!/bin/bash
#SBATCH --job-name=test
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=1
#SBATCH --time=00:00:30
#SBATCH --output=test.out
#SBATCH --error=test.err
#SBATCH --partition=cluster

export OMP_NUM_THREADS=1

module load matlab/2020b

./test.m