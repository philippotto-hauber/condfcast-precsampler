#!/bin/bash
#SBATCH --job-name=simulHS
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=30
#SBATCH --mem=3000
#SBATCH --time=10:00:00
#SBATCH --output=simulHS.out
#SBATCH --error=simulHS.err
#SBATCH --partition=cluster
#SBATCH --constraint=skylake

module load matlab/2020b

mcc -m simul.m -a ./CK1994 -a ./DK2002 -a ./../precsampler -a ./../functions

# HS prec sampler
for i in `seq 61 90`
do
	./simul $i &
done
wait

