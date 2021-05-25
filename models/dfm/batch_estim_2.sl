#!/bin/bash
#SBATCH --job-name=estim2
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=3000
#SBATCH --time=10:00:00
#SBATCH --output=estim2.out
#SBATCH --error=estim2.err
#SBATCH --partition=cluster

module load matlab/2020b

# CK 1994 smoother
for i in `seq 33 64`
do
	./estim_dfm $i &
done
wait

