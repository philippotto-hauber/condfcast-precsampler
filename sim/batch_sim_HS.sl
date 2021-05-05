#!/bin/bash
#SBATCH --job-name=simulHS
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=12:00:00
#SBATCH --output=simulHS.out
#SBATCH --error=simulHS.err
#SBATCH --partition=cluster
#SBATCH --constraint=skylake

module load matlab/2020b

# HS prec sampler
for i in `seq 601 900`
do
	./simul $i &
done
wait

