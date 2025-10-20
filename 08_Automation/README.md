# Week 8 Assignment: Automate a large scale analysis
## Will Vuyk • BMMB852 • 2025-10-19

### Overview
This readme describes how to use this directory's Makefile to 1) download a reference fasta from NCBI and its annotations, and index it and 2) download fastq reads from SRR runs dictated in a design.csv file, run fastqc on those reads, align them to the reference, generate wiggle files, and generate alignment stats in parallel using GNU parallel. 

First, we will collect SRA metadata in a csv format, then run `make ref` to download the reference, and then run a paralelized version of `make reads` to do the rest.

I am using Bioproject `PRJNA313294` from the paper [Tang et al., 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC5299540/) which collected RNAseq data from human cortical neural precursor cells infected with Zika virus.

### Makefile usage
```
@echo "# Makefile for aligning reads from SRA to a genome from NCBI with BWA, and making wiggle file for visualization"
	# Input variables: Genome accession=${ACC}, Interpretable reference name=${NAME}, annotation file types=${ANNOT} (options are: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report), SRA accession=${SRR}, number of reads=${N}"
	# Usage: make [all|ref|reads|fasta|annotations|index|fastq|fastqc|align|stats|wiggle|clean]"
	# make all will run all steps sequentially, make ref will download and index the reference genome and annotations, make reads will download, quality check, align the reads, generate stats, and make wiggle files"    
```

### Get metadata Bioproject metadata with `bio` - did not work 500 server error
```
bio search PRJNA313294 -H --csv > metadata.csv
```

### Work around: get metadata Bioproject metadata with `esearch|efetch`
```
esearch -db sra -query PRJNA313294 | efetch -format runinfo > design.csv
```

### Download reference fasta (Human T2T), annotations, and index. This only needs to happen once, so I have separated it out of the parallelization.
```
make ref ACC=GCF_009914755.1 NAME=HsapiensT2T ANNOT=gff3,gtf
```

### Dry run of parallelized `make reads` using design.csv
```
cat design.csv | \
    parallel --dry-run --colsep , --header : --eta --lb -j 2 \
             make \
             SRR={Run} \
             reads
```

### Parallelized `make reads` using design.csv
```
cat design.csv | \
    parallel --colsep , --header : --eta --lb -j 2 \
             make \
             SRR={Run} \
             reads
```

### Results
This worked like a dream, so cool! I could probably up the thread count, but even at -j 2 it ran fast. I did set N=1000 for the fastq pulls because I did not want to wait multiple hours per alignment, so that would also explain the speed. In the future I will play around more with what read count and thread count my laptop can take. I am also very glad I split the `ref` and `reads` targets because downloading and indexing the human t2t genome takes so long. Only doing that once makes a big difference.
