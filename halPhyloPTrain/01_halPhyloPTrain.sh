#!/bin/sh
#SBATCH -p knl_centos7
#SBATCH -J all_halPhyloPTrain
#SBATCH -n 12
#SBATCH -N 1
#SBATCH --mem=128000
#SBATCH --time=0-48:00
#SBATCH -o all_halPhyloPTrain_%j.out
#SBATCH -e all_halPhyloPTrain_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=gustavo_bravo@fas.harvard.edu

### This script is adapted from that of Sara Wuitchik's at Harvard Informatics  (https://github.com/sjswuitchik/duck_comp_gen/blob/master/03a_cnee_analysis/05_4d_sites.sh)

### 1. Downloading Gallus cds GFF to extract 4d sites

module load Anaconda3/2019.10 

# get galGal6 annotation from NCBI
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/002/315/GCF_000002315.6_GRCg6a/GCF_000002315.6_GRCg6a_genomic.gff.gz
gunzip GCF_000002315.6_GRCg6a_genomic.gff.gz

# clean up GFF to remove partial=true
grep "partial=true" GCF_000002315.6_GRCg6a_genomic.gff | grep "[[:space:]]gene[[:space:]]" | perl -p -e 's/.*(GeneID:\d+).*/$1/' > geneIDs_remove_parts.txt
grep "gene_biotype=protein_coding" GCF_000002315.6_GRCg6a_genomic.gff | grep "[[:space:]]gene[[:space:]]" | perl -p -e 's/.*(GeneID:\d+).*/$1/' > geneIDs_keep_prot.txt
grep -v -f geneIDs_remove_parts.txt GCF_000002315.6_GRCg6a_genomic.gff | grep -f geneIDs_keep_prot.txt > galGal6.filt.gff
sed -i '1i#!gff-spec-version 1.21' galGal6.filt.gff && sed -i '1i##gff-version 3' galGal6.filt.gff
python3 CustomExtractPassFiltMrnaFromGff.py
python3 WriteFilteredGff.py

# convert to GP & BED (for use in CESAR as well) 
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/gff3ToGenePred
wget http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/genePredToBed
chmod +x ./gff3ToGenePred
chmod +x ./genePredToBed

./gff3ToGenePred galGal6.filtpy.gff galGal6.gp
./genePredToBed galGal6.gp galGal6.cds.bed

### 2. Downloading PHAST and dependencies (required by halPhyloPTrain.py) # Perhaps calling phast module is now enough.

wget http://www.netlib.org/clapack/clapack.tgz
tar zxvf clapack.tgz
cd CLAPACK-3.2.1
cp make.inc.example make.inc && make f2clib && make blaslib && make lib

cd ..
wget http://compgen.cshl.edu/phast/downloads/phast.v1_5.tgz
tar zxvf phast.v1_5.tgz
cd phast/src/
make CLAPACKPATH=/n/holyscratch01/edwards_lab/gbravo1/Genomes/03_halPhyloPTrain/CLAPACK-3.2.1 # Adjust path acocrdignly

### 3. Extraction of fourfold degenerate sites and generation of background rate using halPhyloPTrain.py.

# This requires two files files and having the underlying tree estimated independently
# a. Whole-genome alignment: GenomesThamnos.hal
# b. Reference *.bed of Gallus CDS: galGal6.cds.bed
# Notes about some required flags:
  # The name of the reference genome has to match that included in the *.hal alignment

# This will output three files:
# a. antbirds_all_corrected.mod: Background rate based on 4dsites. This file contains the transition matrix and the trix with adjusted branch lengths
# b. galGal6.4ds.bed: Bed file conatining coordinates for 4dsites #I manually renamed this file afterward
# c. allmod.err: Log file

singularity shell --bind /usr/bin/split --cleanenv /n/singularity_images/informatics/cactus/cactus:2019.03.01--py27hdbcaa40_1.sif 
export PATH=$PWD/phast/bin:$PATH
python /usr/local/lib/python2.7/site-packages/hal/phyloP/halPhyloPTrain.py \
--numProc 12 \
--noAncestors \
--substMod SSREV \
--tree "(Gallus_v6:0.098646,(Taenopygia_v1:0.066932,((R_hoffmansi:0.0053487,R_melanosticta:0.0053487):0.02183075,((S_canadensis:0.00662865,S_luctuosus:0.00662865):0.0122772,((T_doliatus:0.01124635,T_ruficapillus:0.01124635):0.00454325,(T_caerulescens:0.01415755,((T_bernardi:0.00158483,T_shumbae:0.00158483):0.00845627,(T_atrinucha:0.00778095,T_bridgesi:0.00778095):0.00226015):0.00411645):0.00163205):0.00311625):0.0082736):0.03975255):0.031714);" \
--targetGenomes Gallus_v6 Taenopygia_v1 R_hoffmansi R_melanosticta S_canadensis S_luctuosus T_doliatus T_ruficapillus T_caerulescens T_bernardi T_shumbae T_atrinucha T_bridgesi \
--precision HIGH \
../01_cactus/GenomesThamnos.hal Gallus_v6 galGal6.cds.bed antbirds_all_corrected.mod 2> allmod.err

