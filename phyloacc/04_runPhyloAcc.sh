#!/bin/bash
#SBATCH -J run_phyloacc
#SBATCH -p serial_requeue
#SBATCH -n 8
#SBATCH -N 1
#SBATCH -t 2-00:00
#SBATCH --mem 32000
#SBATCH --array 0-143
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

source /n/holyscratch01/edwards_lab/gbravo/Genomes/06_5_phyloacc/03_setupPhyloAcc.sh
./PhyloAcc parameters/run${SLURM_ARRAY_TASK_ID}
