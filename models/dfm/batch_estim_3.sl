#!/bin/bash
#SBATCH --job-name=estim3
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=3000
#SBATCH --time=03:00:00
#SBATCH --output=estim3.out
#SBATCH --error=estim3.err
#SBATCH --partition=cluster

module load matlab/2020b

# CK 1994 smoother
for i in `seq 65 84`
do
	./estim_dfm $i &
done
wait

