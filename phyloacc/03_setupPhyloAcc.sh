#!/bin/bash
module purge
module load gcc/7.1.0-fasrc01 armadillo/7.800.2-fasrc02 gsl/2.4-fasrc01
export PATH=/n/holyscratch01/edwards_lab/gbravo/Genomes/06_5_phyloacc/:${PATH}

#this file should be made executable once created
