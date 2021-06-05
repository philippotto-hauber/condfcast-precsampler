#!/bin/bash
#SBATCH --job-name=fore_rest  
#SBATCH --nodes=1
#SBATCH --tasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --mem=20000
#SBATCH --time=05:00:00
#SBATCH --output=fore_rest.out
#SBATCH --error=fore_rest.err
#SBATCH --partition=cluster

module load matlab/2020b

for i in `seq 161 168`
do
	./fore_dfm $i &
done
wait

