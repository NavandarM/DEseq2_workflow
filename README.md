# DEseq2_TEsmall
Differential expression analysis: small RNA

Usages: snakemake -s wf-Deseq.smk 

snakemake pipeline for the DE small RNAs

Requirements:
Edit the config file and update below variables:
-   Indir
-   Outdir
-   MetaData
-   smallestGroupSize (Smallest number of samples per group)
-   DeseqEnv
