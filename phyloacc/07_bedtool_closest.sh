# This bash file uses bedtools to find the closest coding-regions to those accelerated CNEEs as detected by PhyloACC.
# It requires a table containing CNEEs and their coordinates on galGal6 and a bed file containing complete annotations for galGal6.
# It also performs some basic cleaning so it can be read in R for further parsing
# It is meant to be excecuted on FAS Cannon given how bedtools is called. However, if not on Cannon, bedtools must be loaded and called accordingly.

#Loading bedtools
module load bedtools2/2.26.0-fasrc01

#Removing header
sed -i '1d' topZ_CNEEs.txt

#Fixing spacers
sed -i 's/ /\t/g' topZ_CNEEs.txt

#Filtering Gallus bed to only CDS
awk '{ if ($8 == "CDS") { print $0 } }' galGal6.ALL.bed > galGal6.CDS.names.bed

#Getting closest CDs to CNEEs
bedtools closest -a topZ_CNEEs.txt -b galGal6.CDS.names.bed > closest_CDS.txt

#Converting Gene column information into several tab-separated columns
awk '{gsub(";","\t",$0); print;}' closest_CDS.txt > closest_CDS_parsed.txt #not working correctly due to special charcters in galGal6 original bed file. Further cleaning must be done in BBEdit/Excel
