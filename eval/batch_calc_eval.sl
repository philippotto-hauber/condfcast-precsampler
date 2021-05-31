#!/bin/bash
#SBATCH --job-name=calc_eval
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=3000
#SBATCH --time=05:00:00
#SBATCH --output=eval.out
#SBATCH --error=eval.err
#SBATCH --partition=cluster

module load R/4.0.2
R --vanilla --slave < ./calc_eval_hpc.R   
