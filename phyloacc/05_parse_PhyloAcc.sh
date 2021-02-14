#!/bin/sh
#SBATCH -p edwards
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --mem 64000
#SBATCH -t 0-24:00
#SBATCH -J parsing_PhyloAcc
#SBATCH -o parsing_PhyloAcc_%A_%a.out
#SBATCH -e parsing_PhyloAcc_%A_%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

#*_elem_lik is the likelihood, needs to be parsed to remove 0s
#*rate_postZ_M2.txt is posterior probs

mkdir -p parsed_results
#make headers
head outputs/batch000_elem_lik.txt -n 1 > elem_lik.header
head outputs/batch000_rate_postZ_M2.txt -n 1 > rate_postZ_M2.header

#headers: No.     ID      loglik_NUll     loglik_RES      loglik_all      log_ratio       loglik_Max1     loglik_Max2     loglik_Max3
cat outputs/*_elem_lik.txt | awk 'BEGIN {OFS = "\t"} {if ($3 != 0) {print}}'  | grep -v  "^No" > parsed_results/genome_location_combined_elem_lik.temp 
cat outputs/*_rate_postZ_M2.txt | grep -v  "^No" >  parsed_results/genome_location_combined_postZ_M2.temp  

cat elem_lik.header parsed_results/genome_location_combined_elem_lik.temp > parsed_results/genome_location_combined_elem_lik.txt
cat rate_postZ_M2.header parsed_results/genome_location_combined_postZ_M2.temp >  parsed_results/genome_location_combined_postZ_M2.txt

sed -i -e 's/\.\/batch[0-9][0-9][0-9]_output\///g' parsed_results/genome_location_combined_elem_lik.txt

#gzip parsed_results/*.txt
rm parsed_results/*.temp

#Copying useful data to parse results. This is necessary because treeData needs these files to be in the same directory as parsed_results
cp input_data/antbirds_all_corrected.mod parsed_results/
cp outputs/batch000_species_names.txt parsed_results/

#The following files are also necessary and must be copied in advance before proceeding to parsing in R
#This time around files were copied from test run
cp ../06_1_phyloacc/parsed_results/drawAlign_function.R parsed_results/ #source R functions from PhyloAcc
cp ../06_1_phyloacc/parsed_results/scientific_names.txt parsed_results/ #previously created file dictionary 
cp ../06_1_phyloacc/parsed_results/galGal6_final_merged_CNEEs_named.bed parsed_results/ #bed file with CNEE information on Gallus v6 genome
cp ../06_1_phyloacc/parsed_results/galGal6.ALL.bed parsed_results/ #bed file of chicken annotations
cp ../06_1_phyloacc/parsed_results/chicken_chr_dictionary.txt parsed_results/ #dictionary for chicken chromosome names
