# DEseq2_workflow
Differential expression analysis: 
- DEG analysis between two conditions
- Metagenomic differential microbial community
- small RNA (output specificially from <a href="https://github.com/mhammell-laboratory/TEsmall">TEsmall</a> or any tubular raw expression count data)
<br><br>
Usages: snakemake -s wf-Deseq.smk 

snakemake pipeline for the DE small RNAs

Requirements:
Edit the config file and update below variables:
-   Indir
-   Outdir
-   MetaData
-   smallestGroupSize (Smallest number of samples per group)
-   Type: "" # specify if it is smallRNAs otherwise keept --> ""
