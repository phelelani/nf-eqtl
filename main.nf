#!/usr/bin/env nextflow

// CREATE CHANNELS
data_genotype      = Channel.fromPath(params.genotype, type: 'file')
data_snp           = Channel.fromPath(params.snp, type: 'file')
data_ld            = Channel.fromPath(params.ld_regions, type: 'file') 
data_expression    = Channel.fromPath(params.expression, type: 'file')
data_probe_inf     = Channel.fromPath(params.probe_inf, type: 'file')

// SPLIT CHANNELS
data_genotype.into { data_genotype_1; data_genotype_2; data_genotype_3; data_genotype_4 }
data_snp.into { data_snp_1; data_snp_2 }
data_expression.into { data_expression_1; data_expression_2; data_expression_3 }

process run_makePED_MAP {
    
    input:
    file(genotype) from data_genotype_1
    file(snp) from data_snp_1

    output:
    set val("dataset"), file("*.{map,ped}") into pedmap_files
            
    """
    makePED-MAP.pl ${genotype} ${snp}
    """
}
        
process run_PLINK_BED {
            
    input:
    set dataset, file(bedmap) from pedmap_files
    
    output:
    set dataset, file("*.{bed,bim,fam}") into plink_bed_1, plink_bed_2
    
    """
    ## MAKES: {hh,bed,fam,bim,log}
    plink --file ${dataset} --make-bed --out ${dataset} 
    ## MAKES: {sexcheck}
    plink --bfile ${dataset} --check-sex --out ${dataset}

    ## MAKES: {sex_probs}
    grep PROBLEM ${dataset}.sexcheck > ${dataset}.sex_probs

    ## 
    cut -d' ' -f 1,2,6 ${dataset}.fam > ${dataset}.pheno
    """
}

process run_PLINK_MISSING {

    input:
    set dataset, file(set) from plink_bed_1

    output:
    set dataset, file("${dataset}_miss.{bed,bim,fam}") into plink_missing
    set dataset, file("${dataset}_miss.het") into plink_het
    set dataset, file("${dataset}_miss.imiss") into plink_imiss_1, plink_imiss_2
    
    """
    ## MAKES: {hh,bed,fam,bim,log,irem}
    plink --bfile ${dataset} --mind 0.05 --make-bed --out ${dataset}_miss
    ## MAKES: {lmiss,imiss}
    plink --bfile ${dataset} --missing --out ${dataset}_miss
    ## MAKES: {het}
    plink --bfile ${dataset} --het --out ${dataset}_miss
    """
}

process run_PLINK_PRUNING {
    
    input:
    set dataset, file(set) from plink_missing
    file(ld) from data_ld

    output:
    set dataset, file("${dataset}_prunned.{bed,bim,fam}") into plink_pruning
    set dataset, file("${dataset}_prunned.genome") into plink_genome
    // set dataset, file("${dataset}_prunned.pca.*") into plink_smartpca

    """
    ## MAKES: {prune.in,.prune.out}
    plink --bfile ${dataset}_miss --exclude ${ld} --range --indep-pairwise 50 5 0.2 --out ${dataset}

    ## MAKES: {_pruned.hh,_pruned.bed,_pruned.fam,_pruned.bim,_pruned.log} 
    plink --bfile ${dataset}_miss --extract ${dataset}.prune.in --make-bed --out ${dataset}_prunned

    ## MAKES: {genome}
    plink --bfile ${dataset}_prunned --genome --min 0.05 --out ${dataset}_prunned

    runpca.sh ${dataset}_prunned
    """
}

plink_imiss_1.join(plink_het).map {
    it -> [ it[0], [ it[1], it[2] ] ]
}.set { imiss_het }

process run_ExtremeHET {
    publishDir "$PWD/outputs/extreme_het", mode: 'copy', overwrite: true

    input:
    set dataset, file(set) from imiss_het

    output:
    set dataset, file("*") into extreme_het

    """
    Rscript /home/phelelani/projects/jenny/bin/R_QC.R ${set.get(0)} ${set.get(1)}
    """
}

plink_imiss_2.join(plink_genome).map {
    it -> [ it[0], [ it[1], it[2] ] ]
}.set { imiss_genome }

process run_IdentyByDescent {
    // publishDir "$PWD/outputs/identity_by_descent", mode: 'copy', overwrite: true

    input:
    set dataset, file(set) from imiss_genome

    output:
    set dataset, file("fail_IBD.txt") into failed_IBD

    """
    run-IBD-QC.pl ${set.get(0)} ${set.get(1)}
    """
}

process run_SNP_QC {
    
    input:
    set dataset, file(set) from plink_bed_2
    
    output:
    file("*.bim") into snpqc_bim

    """
    plink --bfile ${dataset} --geno 0.065 --maf 0.01 --hwe 0.00001 --make-bed --out ${dataset}_snp_qc
    """
}

snpqc_bim.into { snpqc_bim_1; snpqc_bim_2 }

process run_PCA {
    publishDir "$PWD/outputs/pca_info", mode: 'copy', overwrite: true
    
    input:
    file(expression) from data_expression_1
    
    output:
    file("PCA_*") into pca_info

    """
    sed '/^!/d; /^\$/d' ${expression} > data_expression_matrix
    Rscript /home/phelelani/projects/jenny/bin/jenny_PCAplot_rvsd.R data_expression_matrix
    """
}

process run_REF_Mapping {
    publishDir "$PWD/outputs/", mode: 'copy', overwrite: true
    
    input:
    file(genotype) from data_genotype_2
    file(expression) from data_expression_2

    output:
    set val("dataset"), file("*_mapping.txt") into mapping_refs

    """
    mapping_reference.pl ${genotype} && mv mapping_reference_out.txt geno_mapping.txt
    mapping_reference.pl ${expression} && mv mapping_reference_out.txt expr_mapping.txt
    """
}

process run_makeCovarSNPLocFiles {
    publishDir "$PWD/outputs/", mode: 'copy', overwrite: true, pattern: "eqtl_*"
    input:
    file(snp) from data_snp_2
    file(genotype) from data_genotype_3

    output:
    file("eqtl_snploc.txt") into snploc_file
    file("eqtl_covariate.txt") into covar_file
    file("header.txt") into sample_headers

    """
    ## COVAR FILE
    sed -n '/!Sample_title/p; /!Sample_characteristics_ch1\t\"gender:/p; /!Sample_characteristics_ch1\t\"age:/p' ${genotype} > tmp
    sed -i 's/"//g; s/!Sample_title/id/g; s/age: //g; s/gender: //g' tmp
    sed -i 's/female/1/g; s/male/0/g' tmp
    sed -i '0,/!Sample_characteristics_ch1/s//age/; 0,/!Sample_characteristics_ch1/s//gender/' tmp
    mv tmp eqtl_covariate.txt
    sed -n '1p' eqtl_covariate.txt > header.txt 

    ## SNPLOC FILE
    grep "^IlmnID\\|^rs" ${snp} | cut -d ',' -f 2,10,11  > eqtl_snploc.txt 
    sed -i 's/Name/snp/; s/Chr/chr/; s/MapInfo/pos/' eqtl_snploc.txt
    for i in {1..22}; do sed -i 's/,'"\$i"',/,'"chr\$i"',/' eqtl_snploc.txt; done
    sed -i 's/,X,/,chrX,/; s/XY/chrXY/; s/,/\\t/g' eqtl_snploc.txt
    """
}

process run_matchSNPOrder {

    input:
    file(bim) from snpqc_bim_1
    file(snploc) from snploc_file

    output:
    file("snploc_matched.txt") into snp_matched

    """
    map_snploc.pl ${bim} ${snploc}
    sed '1i\\snp\\tchr\\tpos' snploc_matched.txt > tmp
    mv tmp snploc_matched.txt
    """
}

process run_makeGenotypeFile {
    publishDir "$PWD/outputs/", mode: 'copy', overwrite: true

    input: 
    file(bim) from snpqc_bim_2
    file(head) from sample_headers
    file(genotype) from data_genotype_4

    output:
    file("eqtl_genotype.txt") into genotype_file

    """
    grep "^\\"rs" ${genotype} > tmp_genotype_1

    make_genotype.pl tmp_genotype_1
    mv tmp tmp_genotype_2

    map_bim_genotype.pl ${bim} tmp_genotype_2
    cat header.txt tmp > eqtl_genotype.txt
    """
}

process run_makeExpressionNorm {
    publishDir "$PWD/outputs/", mode: 'copy', overwrite: true, pattern: "gene_expression_norm"

    input:
    file(expression) from data_expression_3
    file(probe) from data_probe_inf

    output:
    file("gene_expression_norm") into gene_expr_norm
    file("data_probes") into probe_file

    """
    sed '/^!/d; /^\$/d; /^"ID_REF/d; s/"//g' ${expression} > data_expression_matrix
    grep ^Homo ${probe} > data_probes

    map_illumina_geneid.pl data_probes data_expression_matrix

    cut -f 2- data_expression_matrix > tmp_matrix
    paste tmp_list tmp_matrix > gene_expression_norm

    """
}


process run_makeGeneLOC {
    publishDir "$PWD/outputs/", mode: 'copy', overwrite: true

    input:
    file(probe) from probe_file

    output:
    file("gene_location_file.txt") into gene_loc

    """
    probe_coordiantes.pl ${probe}
    find_chr_no_pos.pl
    remove_bad_chr_no.pl
    """
}
