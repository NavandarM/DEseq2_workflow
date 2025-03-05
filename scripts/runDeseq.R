library("ggplot2")
library("ggrepel")
library("tidyverse")
library("DESeq2")

args <- commandArgs(trailingOnly = TRUE)

# Access file paths from arguments
counts_file <- args[1]
metadata_file <- args[2]
vsd_file <- args[3]
nrc_file <- args[4]
pca_file <- args[5]
vol_file <- args[6]
DE_file <- args[7]

## PCA function
PCA_tm <- function(dds, groups="condition", trans_func=vst){

  # Define color and shape variables - set to NULL if not used
  color_var <- if( length(groups) > 0) { sym(groups[1]) } else { NULL }
  print(color_var)
  
  # transformation | PCA 
  PCA <- dds %>% trans_func %>% plotPCA(intgroup=groups, returnData=TRUE)
  # get percentage explained variation per PC
  percentVar <- round(100 * attr(PCA, "percentVar"), 1)
  
  # Add sample names to the PCA data (rownames are the sample names)
  PCA$name <- gsub("","", PCA$name)
  
  # Plot PCA with ggplot and add sample names using geom_text_repel
  p <- ggplot(PCA, aes(x=PC1, y=PC2, color={{color_var}})) +
    geom_point(size=6, alpha=0.5) +
    geom_text_repel(aes(label=name), size=5, show_guide = F) +  # Add sample names as labels
    xlab(paste0("PC1: ",percentVar[1], "%")) +
    ylab(paste0("PC2: ",percentVar[2], "%")) +
    scale_color_manual(values=c("dodgerblue", "darkorange")) +
    theme_bw() +
    theme(axis.text = element_text(size = 17)) +
    theme(axis.title = element_text(size = 17))
  
  ggsave(filename = pca_file, plot = p, width = 12, height = 12, dpi = 300, units = "in")
  return(p)
  
}

##############

VolcanoPlot <- function(res, padj_cutoff=0.05, label_length = 20) {
  # Filter significant genes based on padj_cutoff
  filter <- res[res$padj < padj_cutoff, ]
  Up <- filter[filter$log2FoldChange > 0, ]
  Down <- filter[filter$log2FoldChange < 0, ]
  
  write.table(filter, DE_file, sep="\t", quote=F)
  
  # Get the top 20 upregulated and downregulated genes
  top_Up <- Up[order(-Up$log2FoldChange), ][1:label_length, ]
  top_Up$Names <- sub("^([^:]+:[^:]+):.*", "\\1", row.names(top_Up))
  
  top_Down <- Down[order(Down$log2FoldChange), ][1:label_length, ]
  top_Down$Names <- sub("^([^:]+:[^:]+):.*", "\\1", row.names(top_Down))
  
  # Combine top genes for labeling
  top_genes <- rbind(top_Up, top_Down)
  
  # Create a custom label for the legend with extra spacing
  legend_labels <- c("Non-Significant",
    paste("\nSignificant\nUp:", nrow(Up), "\nDown:", nrow(Down))  # Extra newline before "Significant"
  )
  
  # Create the volcano plot
  p <- ggplot(data=res, aes(x=log2FoldChange, y=-log10(padj))) +
    geom_point(aes(color = padj < padj_cutoff), size=1.5) +
    scale_color_manual(name="", 
                       values=c('FALSE'='#7f7f7f', 'TRUE'='#f62728'),
                       labels=legend_labels) +  # Updated legend labels
    
    # Annotate with the top 10 up and downregulated gene names
    geom_text_repel(data=top_genes, aes(label=Names),
                    size=4, max.overlaps=40) +
    
    # Customize the theme
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          axis.text = element_text(size = 14),
          axis.title = element_text(size = 14),
          legend.text = element_text(size = 10),
          legend.spacing.y = unit(1, 'cm')) +  # Increase vertical spacing in legend
    guides(color = guide_legend(byrow = TRUE))  # Ensure each label appears in a separate row
  
  ggsave(filename = vol_file, plot = p, width = 12, height = 12, dpi = 300, units = "in")
}

#### Actual code:

Undata <- read.delim(counts_file)
data <- Undata
colnames(data)
data$Ids <- make.unique(data$fid)
Count_Matrix <- data
data$fid <- NULL
data$ftype <- NULL
row.names(data) <- data$Ids
data$Ids <- NULL

metadata <- read.delim(metadata_file)
metadata$sample <- as.factor(metadata$sample)
metadata$condition <- as.factor(metadata$condition)

Design <- ~ 1 + condition
# Laoding the DE-seq data
dds <- DESeqDataSetFromMatrix(countData = data,
                              colData = metadata,
                              design= Design)

smallestGroupSize <- 3
keep <- rowSums(counts(dds) >= 10) >= smallestGroupSize
dds <- dds[keep,]

dds <- DESeq(dds, fitType="local")

dds <- estimateSizeFactors(dds)

par <- estimateDispersions(dds, fitType="local")

plotDispEsts(par)

Name =  paste0(colnames(metadata)[2], "_",unique(metadata$condition)[1], "_vs_", unique(metadata$condition)[2])

res <- results(dds,  name=resultsNames(dds)[2])

res <- res %>% data.frame() %>% drop_na()

NormalizedCounts <- counts(dds,normalized=TRUE)
write.table(NormalizedCounts, nrc_file, sep='\t', quote = F)

vsd <- vst(dds, blind=FALSE, fitType="local")
write.table(assay(vsd), vsd_file, sep='\t', quote = F)

VolcanoPlot(res, 0.1, 10)
PCA_tm(dds)