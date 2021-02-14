#!/bin/sh
#SBATCH -p edwards
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem 8000
#SBATCH -t 0-24:00
#SBATCH -J parsing_PhyloAcc
#SBATCH -o parsing_PhyloAcc_%A_%a.out
#SBATCH -e parsing_PhyloAcc_%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

## 1. Creating a directory to parse results

mkdir -p parsed_results

## 2. Combining results from separate runs into single files: a) *elem_lik.txt & b) rate_postZ_M2.txt

# *elem_lik: Likelihood information. This needs to be parsed to remove 0s
# *rate_postZ_M2.txt: Posterior probabilities

# Making headers that will go into the combined files. These are basically the same headers from each batch's output

head outputs/batch000_elem_lik.txt -n 1 > elem_lik.header
head outputs/batch000_rate_postZ_M2.txt -n 1 > rate_postZ_M2.header

# Combining files

cat outputs/*_elem_lik.txt | awk 'BEGIN {OFS = "\t"} {if ($3 != 0) {print}}'  | grep -v  "^No" > parsed_results/genome_location_combined_elem_lik.temp 
cat outputs/*_rate_postZ_M2.txt | grep -v  "^No" >  parsed_results/genome_location_combined_postZ_M2.temp  

cat elem_lik.header parsed_results/genome_location_combined_elem_lik.temp > parsed_results/genome_location_combined_elem_lik.txt
cat rate_postZ_M2.header parsed_results/genome_location_combined_postZ_M2.temp >  parsed_results/genome_location_combined_postZ_M2.txt

# To maintain the CNEE name without its path in a single column, I am removing the path from the name of each CNEE. This is helpful for downstream data wrangling in R.
sed -i -e 's/\.\/batch[0-9][0-9][0-9]_output\///g' parsed_results/genome_location_combined_elem_lik.txt

# Get rid of temporary files.
rm parsed_results/*.temp

## 3, Copying necessary files for parsing results in R.

# Tree files and species names. This is necessary because for some reason treeData needs these files to be in the same directory as parsed_results. It doesn't work if called from their original location when in R.
cp input_data/antbirds_all_corrected.mod parsed_results/
cp outputs/batch000_species_names.txt parsed_results/

# The following files are also necessary and must be copied in advance before proceeding to parsing in R. This time around files were copied from test run (06_1_phyloacc). Modify origin as required.

cp ../06_1_phyloacc/parsed_results/drawAlign_function.R parsed_results/ #source R functions from PhyloAcc
cp ../06_1_phyloacc/parsed_results/scientific_names.txt parsed_results/ #previously created file dictionary 
cp ../06_1_phyloacc/parsed_results/galGal6_final_merged_CNEEs_named.bed parsed_results/ #bed file with CNEE information on Gallus v6 genome
cp ../06_1_phyloacc/parsed_results/galGal6.ALL.bed parsed_results/ #bed file of chicken annotations
cp ../06_1_phyloacc/parsed_results/chicken_chr_dictionary.txt parsed_results/ #dictionary for chicken chromosome names
