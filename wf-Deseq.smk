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
        expand(os.path.join(Outdir, 'TEsmallOut','deseq_results.done'))

rule deseq2_analysis:
    input:
        counts= os.path.join(Indir, 'TEsmallOut','count_summary.txt'),
        metadata=MetaData
    output:
        result= os.path.join(Outdir,'TEsmallOut','deseq_results.done')
    shell:"""
        Rscript runDeseq.R {input.counts} {input.metadata}
        touch {output.result}
    
    """
    