#!/bin/bash
#SBATCH --job-name=simulCK
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=12:00:00
#SBATCH --output=simulCK.out
#SBATCH --error=simulCK.err
#SBATCH --partition=cluster
#SBATCH --constraint=skylake

module load matlab/2020b

# CK 1994 smoother
for i in `seq 1 300`
do
	./simul $i &
done
wait

