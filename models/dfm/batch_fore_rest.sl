#!/bin/bash
#SBATCH --job-name=fore_rest  
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=3000
#SBATCH --time=05:00:00
#SBATCH --output=estim1.out
#SBATCH --error=estim1.err
#SBATCH --partition=cluster

module load matlab/2020b

for i in `seq 224 252`
do
	./fore_dfm $i &
done
wait

