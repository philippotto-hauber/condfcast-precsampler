#!/bin/bash
#SBATCH --job-name=simulDK
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=12:00:00
#SBATCH --output=simulDK.out
#SBATCH --error=simulDK.err
#SBATCH --partition=cluster
#SBATCH --constraint=skylake

module load matlab/2020b

# DK 2002 smoother
for i in `seq 301 600`
do
	./simul $i &
done
wait

