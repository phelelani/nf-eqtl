#!/usr/bin/env Rscript

.libPaths("/home/phelelani/R/x86_64-redhat-linux-gnu-library/3.6")

## GET ARGUEMENTS
args = commandArgs(trailingOnly=TRUE)
cat(args, sep = "\n")

# plyr
if (!require(plyr, quietly=TRUE)) {
  install.packages("plyr")
  library(plyr)
}

# dplyr
if (!require(dplyr, quietly=TRUE)) {
  install.packages("dplyr")
  library(dplyr)
}

# ggplot2
if (!require(ggplot2, quietly=TRUE)) {
  install.packages("ggplot2")
  library(ggplot2)
}

 # ggrepel
if (!require(ggrepel, quietly=TRUE)) {
  install.packages("ggrepel")
  library(ggrepel)
}

# import data set
jenny <- read.table(args[1], header = T, sep = "\t")
#jenny <- read.table("/home/phelelani/projects/jenny/test/data_expression_matrix", header = TRUE, sep = "\t")

# convert your data into a data frame
jenny <- as.data.frame(jenny)

# make first column as rownames,
# because its an IDs column and not sample data
rownames(jenny) <- jenny$ID_REF

# delete/remove first column
jenny <- jenny[, -1]

# Do PCA calculation on dataframe:
pca_jenny=prcomp(t(jenny))

# Calculate % variance covered by component to show on X and Y axis for PC1 and PC2
pca_jenny_perc=round(100*pca_jenny$sdev^2/sum(pca_jenny$sdev^2),1)

#Create dataframe with PC1 and PC2 with some metadata:
pca_jenny_df=data.frame(PC1 = pca_jenny$x[,1], 
                        PC2 = pca_jenny$x[,2], 
                        sample = colnames(jenny))

# draw PCA
ggplot(pca_jenny_df, aes(PC1,PC2))+
  geom_point(size=3) +
  geom_text_repel(aes(label=sample),
                  box.padding = unit(0.45, "lines")) +
  labs(x=paste0("PC1 (",pca_jenny_perc[1],"%)"), y=paste0("PC2 (",pca_jenny_perc[2],"%)"))

# if you want both color and labels
# *it would make more sense to use color for each of the conditions and not for 
#   inidividual samples

# draw PCA
pdf("PCA_plot.pdf", paper="a4r", onefile=FALSE)
ggplot(pca_jenny_df, aes(x=PC1, y=PC2))+
    geom_point(size=1, show.legend = FALSE) +
    theme_bw() +
    ## geom_text_repel(aes(label=sample), size=5, box.padding = unit(0.45, "lines")) +
    geom_text_repel(aes(label=sample),
                    size=1.5, min.segment.length = 0.4,
                    segment.size = 0.1, box.padding = 0.5,
                    direction = "both",
                    hjust = 1) +
    labs(x=paste0("PC1 (",pca_jenny_perc[1]," %)"), y=paste0("PC2 (",pca_jenny_perc[2]," %)"))
dev.off()

## Variance plot
pdf("PCA_variance.pdf", paper="a4r", onefile=FALSE)
screeplot(pca_jenny)
screeplot(pca_jenny, npcs = 206, type = "lines")
dev.off()
