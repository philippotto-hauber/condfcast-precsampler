#!/bin/bash
#SBATCH --job-name=calc_eval
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=3000
#SBATCH --time=05:00:00
#SBATCH --output=calc_eval.out
#SBATCH --error=calc_eval.err
#SBATCH --partition=cluster

cd  $PBS_O_WORKDIR

module load R3.6.0
R --vanilla --slave < ./calc_eval_hpc.R   
