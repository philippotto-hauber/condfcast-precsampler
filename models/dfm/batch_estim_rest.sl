#!/bin/bash
#SBATCH --job-name=estim_rest  
#SBATCH --nodes=1
#SBATCH --tasks-per-node=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=20000
#SBATCH --time=05:00:00
#SBATCH --output=estim_rest.out
#SBATCH --error=estim_rest.err
#SBATCH --partition=cluster

module load matlab/2020b

for i in `seq 161 184`
do
	./estim_dfm $i &
done
wait

