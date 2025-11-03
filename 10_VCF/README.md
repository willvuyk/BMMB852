# Week 10 Assignment: Generate a multi-sample VCF
## Will Vuyk • BMMB852 • 2025-11-02

This week the assignment is to expand the makefile from last week (week 8 and 9) to create VCF files as well. I modified the week 8 and 9 makefile to add a new target `vcf` that requires the `REF` and `BAM` variables. This vcf target was modified from code in the bcftools.mk file in the bio code toolbox. 


## Make BAMs
To make the BAM files I use moving forward, please do the following (which is explained in more detail in the week 8 README)

```
### Make design file with `esearch|efetch`
```
esearch -db sra -query PRJNA313294 | efetch -format runinfo > design.csv
```

### Download reference fasta (Human T2T chr 22), annotations, and index. This only needs to happen once, so I have separated it out of the parallelization.
```
make ref ACC=NC_060948.1 NAME=HsapiensT2T_Chr22 ANNOT_ACC=GCF_009914755.1 ANNOT=gff3,gtf
```

### Parallelized `make reads` using design.csv
```
cat design.csv | \
    parallel --colsep , --header : --eta --lb -j 2 \
             make \
             SRR={Run} \
             reads
```

## Make VCFs

### To call variants in a single sample for which you already have a BAM file, use:
```
make vcf BAM=bam/SRR3191542.bam
```

### To make BAMs and call variants on all samples in the design file, use: 
```
cat design.csv | \
    parallel --colsep , --header : --eta --lb -j 2 \
             make \
             SRR={Run} \
             readsvcf
```

## Merge VCFs
This command merges all .vcf.gz files in the vcf directory into a single new file called `merged.vcf.gz`
```
bcftools merge vcf/*.vcf.gz -Oz -o vcf/merged.vcf.gz
```

## Images of alignments and vcfs in IGV

