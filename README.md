## EQTL Workflow

<p align="center">
    <img width="1200" src="nf-eqtl.png">
</p>

### 1. Download workflow and data!
```console
git pull https://github.com/phelelani/nf-eqtl.git
```

Download the data needed to run the workflow and move it into the `data` folder (create it!) in the repository.

### 2. Set parameters
Edit the `myfiles.config` file with the necessary files you downloaded!
```console
//USER INPUT PARAMETERS
params {
    genotype    = "data/GSE39036_series_matrix.txt"
    snp         = "data/GPL6980_HumanHap300v2_A.csv"
    ld_regions  = "data/high-LD-regions.txt"
    expression  = "data/GSE32504_series_matrix.txt"
    probe_inf   = "data/Probe_and_control_probe_info.txt"
}
```

### 3. Run the workflow
```console
nextflow run main.nf -profile slurm -c myfiles.config
```

### 4. Remove failed samples
`<failed_genotype>` and  `<failed_expression>` below are the list of sampled that failed QC! 
```console
perl remove_samples.pl outputs/geno_mapping.txt outputs/expr_mapping.txt <failed_genotype> <failed_expression>
```

### 5. Run the R script
```console
Rscript cis_trans_eqtl.R
```

### 6. Results in the `outputs` folder:
```console
outputs
  |--cis_eqtls_removed_1e6_1e-6.txt      ## 
  |--eqtl_snploc.txt                     ## 
  |--extreme_het                         ## 
     |--pairs.imiss-vs-het.pdf           ## 
  |--geno_mapping.txt                    ## 
  |--trans_eqtls_removed_1e6_1e-6.txt    ## 
  |--eqtl_covariate.txt                  ## 
  |--expression_remove.txt               ## 
  |--gene_expression_norm                ## 
  |--genotype_remove.txt                 ## 
  |--eqtl_genotype.txt                   ## 
  |--expr_mapping.txt                    ## 
  |--gene_location_file.txt              ## 
  |--histogram.pdf                       ## 
  |--pca_info                            ## 
     |--PCA_plot.pdf                     ## 
     |--PCA_variance.pdf                 ## 
```
