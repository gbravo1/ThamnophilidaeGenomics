#### These scripts to run PhyloAcc (https://doi.org/10.1093/molbev/msz049) were writtten largely based on those made available by Zhirou Hu (https://github.com/xyz111131/PhyloAcc) and Sara Wuitchick (https://github.com/sjswuitchik/duck_comp_gen).

### *How target species were defined to run PhyloAcc?*

Dry habitats rather represent one extreme in a contunium from humid/forested to dry/open environments. Therefore, species may occur along different portions of such continuum, some being more prone to occur in dryier regions than others. Defining a binary variable of dry vs humid is not straightforward.

Therefore, **three different** strategies were used to run PhyloAcc:

1. Based on the precipitation of the dryest quarter at the locality of the specimen used to generate the reference genome.

	**Target species: *T. bernardi*, *T. ruficapillus*, *T. caerulescens*, *T. doliatus* & *S. canadensis*.**
  
2. Based on the tree coverage at the locality of the specimen used to generate the reference genome.

	**Target species: *T. bernardi*, *S. canadensis*, *T. caerulescens*,*T. shumbae* & *T. ruficapillus*.** 
	
3. Based on the classification of the species as dry- or humid-habitat specialist in family-level analyses (Bravo et al. in prep). This classification used information from complete ranges of all species and the precipitation and temperature conditions therein.

	**Target species: *T. bernardi*, *S. canadensis*, *T. shumbae* & *T. doliatus*.** 

Outputs of these analyses were processed independently to then define elements accelarated in all analyses. 

### **The scripts contained herein are suited for the first strategy.** 
