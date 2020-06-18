## EQTL PIPELINE

```
nextflow run main.nf -profile slurm -c myfiles.config
```

```
perl bin/remove_samples.pl ${map_geno} ${map_expr} ${fail_geno} ${fail_expr}     
```

```
Rscript cis_trans_eqtl.R
```

