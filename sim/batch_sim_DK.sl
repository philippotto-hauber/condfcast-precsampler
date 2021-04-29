#!/bin/bash
#SBATCH --job-name=simulDK
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=10:00:00
#SBATCH --output=simulDK.out
#SBATCH --error=simulDK.err
#SBATCH --partition=cluster
#SBATCH --constraint=skylake

# DK 2002 smoother
for i in `seq 31 60`
do
	./simul $i &
done
wait

