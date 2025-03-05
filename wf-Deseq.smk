import yaml
import os
import glob

configfile: "deseq2_config.yaml"

Indir = config["Indir"]
Outdir = config["Outdir"]
MetaData = config["MetaData"]
smallestGroupSize = config['smallestGroupSize']

rule all:
    input:
        expand(os.path.join(Indir, 'TEsmallOut','count_summary.txt')),
        expand(os.path.join(Outdir, 'DEoutput','VarianceStabilizedCounts.txt')),
        expand(os.path.join(Outdir, 'DEoutput','Normalized_Read_Counts.txt')),
        expand(os.path.join(Outdir, 'DEoutput','Pcaplot.pdf')),
        expand(os.path.join(Outdir, 'DEoutput','volcanoplot.pdf')),
        expand(os.path.join(Outdir, 'DEoutput','DEGs_GF_vs_Conv.txt')),
        expand(os.path.join(Outdir, 'DEoutput','deseq_results.done'))

rule deseq2_analysis:
    input:
        counts= os.path.join(Indir, 'TEsmallOut','count_summary.txt'),
        metadata=MetaData
    output:
        vsc = os.path.join(Outdir, 'DEoutput','VarianceStabilizedCounts.txt'),
        nrc = os.path.join(Outdir, 'DEoutput','Normalized_Read_Counts.txt'),
        pca = os.path.join(Outdir, 'DEoutput','Pcaplot.pdf'),
        vol = os.path.join(Outdir, 'DEoutput','volcanoplot.pdf'),
        DE = os.path.join(Outdir, 'DEoutput','DEGs_GF_vs_Conv.txt'),
        flag = os.path.join(Outdir, 'DEoutput','deseq_results.done')

    conda:
        config["DeseqEnv"]
    shell:"""
        Rscript scripts/runDeseq.R {input.counts} {input.metadata} {output.vsc} {output.nrc} {output.pca} {output.vol} {output.DE}
        touch {output.flag}
    
    """
    
