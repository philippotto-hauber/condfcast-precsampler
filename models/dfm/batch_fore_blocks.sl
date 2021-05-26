#!/bin/bash
#SBATCH --job-name=fore_blocks  
#SBATCH --array=1-7
#SBATCH --nodes=1
#SBATCH --tasks-per-node=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=3000
#SBATCH --time=05:00:00
#SBATCH --output=estim1.out
#SBATCH --error=estim1.err
#SBATCH --partition=cluster

module load matlab/2020b

#Startnummer_32erblock (start=1 --> beginnen mit 1tem 32er Block; start=2 --> beginnen mit 2. 32er Block
START=1
OFFSET=$(($START+(${SLURM_ARRAY_TASK_ID}-1)*32))

for i in `seq 0 31`;
do
# Berechnung der zu verwendenden Eingabedatei
  ACTUAL_ID=$(($i+$OFFSET))
 ./fore_dfm $ACTUAL_ID > ausgabe_job$ACTUAL_ID.out &
done
wait

