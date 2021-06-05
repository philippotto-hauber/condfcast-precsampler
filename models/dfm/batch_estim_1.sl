#!/bin/bash
#SBATCH --job-name=estim1
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=10000
#SBATCH --time=05:00:00
#SBATCH --output=estim1.out
#SBATCH --error=estim1.err
#SBATCH --partition=cluster

module load matlab/2020b

# CK 1994 smoother
for i in `seq 1 32`
do
	./estim_dfm $i &
done
wait

