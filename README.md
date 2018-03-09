# Pipeline to perform differential transcript analysis with transcriptomes
## By: Erin M. Roberts
## 8/22/17

This pipeline includes scripts for the following processes for both C. gigas and C. virginica transcriptomes:
1. Adapter trimming, quality trimming using BBTools
2. Mapping with HISAT2 to the reference genome
3. Alignment with Stringtie to the reference annotation
4. Differential Transcript analysis of count data with DESeq2
5. Gene set enrichment analysis (GSEA) with topGO

The /SCRIPTS folder contains bash scripts to be executed from a cluster computing environment. The /Bac_Viral_Subset
folder contains scripts to process C. gigas transcriptomes. The /C_Virginica_Subset folder contains scripts to process
C. virginica transcriptomes. 

The DESeq2 folder contains R scripts to perform DESeq2 differential transcript analysis, GSEA, and network analysis.
Scripts again are separated into separate folders by species. 

To cite this work: Roberts, E.M. 2017."Pipeline to perform differential expression analysis with transcriptomes".
https://github.com/erinroberts/apoptosis_data_pipeline. The University of Rhode Island. 
 


