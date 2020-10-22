#!/bin/bash
#SBATCH -J input_phyloacc
#SBATCH -o input_phyloacc_%j.out
#SBATCH -e input_phyloacc_%j.err
#SBATCH -n 1
#SBATCH -N 1
#SBATCH -t 7-00:00
#SBATCH -p edwards
#SBATCH --mem=8000
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

cd ~/06_phyloacc

### 1. Creating directory to store input data
mkdir input_data 
cd input_data

### 2. Copying input data
cp ../../05_cnees/alignments/aligned/cnee_nomissing_gapFixed.fa . # output of script 01_concatenation.sh
cp ../../05_cnees/alignments/aligned/cnee_nomissing.part.bed . # output of script 01_concatenation.sh
cp../../04_halTreePhyloP/antbirds_all_corrected.mod . # this files comes from running halTreePhyloP on the hal whole-genome alignment
cd ..

### 3. Setting up batches of 2000 elements each to run PhyloAcc on each in an array. Each batch will contain randomenly selected CNEEs

# Creating directory to store list of CNEEs in each batch
mkdir -p batches

# Getting total number of elements in our fasta alignment 
wc -l input_data/cnee_nomissing.part.bed

# Shuffling lines in random order with 0-n-1 from wc -l above
shuf -i 0-286456 > batches/full_list 

# Creating input files
split -d -a 3 -l 2000 batches/full_list batches/batch

### 4. Setting up up parameter files
# Creating directory to store parameter files. Each batch will have its oen parameter file
mkdir -p parameters

cd batches

#Writing parameter files
for I in $(seq 0 143); # 143 is number of batches generated above. Adjust accordingly.
do
  printf -v BATCH "%03d" $I
  PARTFILE=batches/batch$BATCH
  PREFIX=batch${BATCH}
  cat > ../parameters/run$I <<EOF 
PHYTREE_FILE /n/holyscratch01/edwards_lab/gbravo/Genomes/06_phyloacc/input_data/antbirds_all_corrected.mod
SEG_FILE /n/holyscratch01/edwards_lab/gbravo/Genomes/06_phyloacc/input_data/cnee_nomissing.part.bed
ALIGN_FILE /n/holyscratch01/edwards_lab/gbravo/Genomes/06_phyloacc/input_data/cnee_nomissing_gapFixed.fa
RESULT_FOLDER /n/holyscratch01/edwards_lab/gbravo/Genomes/06_phyloacc/outputs/
PREFIX $PREFIX
ID_FILE $PARTFILE
CHAIN 1
BURNIN 1000
MCMC 4000
CONSERVE_PRIOR_A 5
CONSERVE_PRIOR_B 0.04
ACCE_PRIOR_A 10
ACCE_PRIOR_B 0.2
HYPER_GRATE_A 3
HYPER_GRATE_B 1
OUTGROUP Gallus_v6;Taenopygia_v1
TARGETSPECIES S_canadensis;T_ruficapillus;T_bernardi;T_shumbae;
CONSERVE R_hoffmansi;R_melanosticta;S_luctuosus;T_atrinucha;Tbridgesi
GAPCHAR -
NUM_THREAD 8
VERBOSE 0
CONSTOMIS 0.01
GAP_PROP 0.8
TRIM_GAP_PERCENT 0.8
EOF
done

### 5. Creating output directory
mkdir -p outputs
