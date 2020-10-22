#!/bin/bash
#SBATCH -J concatenations
#SBATCH -o concatenations_%j.out
#SBATCH -e concatenations_%j.err
#SBATCH -n 32
#SBATCH -N 1
#SBATCH -t 1-00:00
#SBATCH -p edwards
#SBATCH --mem=64000
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

### 1.Moving to the folder containing a set of 375 folders containing 1000 fasta alignments each resulting from MAFFT
#example: ~/05_cnees/alignments/aligned/batch001_output
cd ~/05_cnees/alignments/aligned

### 2.Selecting files to concatenate for PhyloAcc
# I did this because I wanted to restrict analyses to CNEEs with no missing data

#Generating a list with path for all fastas
find . -name '*.fa' > list

#Tallying number of sequences in each alignment
awk '{ if ($1 == 13) { print $2 } }' tally.txt > loci_to_use.txt
sed -e 's/^\.\///g' loci_to_use.txt > list_loci_to_use.txt

#Extracting paths for only those loci with no missing data
grep -Fwf list_loci_to_use.txt list > list_loci_no_missing_data.txt

### 3.Getting ready for concatenating sequences
#Cloaning catsequences
git clone  --branch seqname https://github.com/harvardinformatics/catsequences.git
cd catsequences/
cc catsequences.c -o catsequences -lm
cd ..

### 4.Executing catsequences using the list of loci with no missing taxa
#catsequences generates a fasta file containing all the alignments in the provided list and the partition file
catsequences/catsequences list_loci_no_missing_data.txt

#renaming output files 
mv allseqs.fas cnee_nomissing.fa
mv allseqs.partitions.txt cnee_nomissing.partitions.txt
