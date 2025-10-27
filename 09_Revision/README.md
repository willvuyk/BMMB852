# Week 9 Assignment: Revision of "Automate a large scale analysis" from last week
## Will Vuyk • BMMB852 • 2025-10-19

### Revisions
This week's homework revises last week's homework based upon comments from Istvan on the course website. The comments on my assignment last week were:

Use `bio` instead of `efetch` 
*I have tried `bio` again and it still does not work*
```
Error for https://www.ebi.ac.uk/ena/portal/api/filereport, {'accession': 'PRJNA313294', 'fields': 'run_accession,sample_accession,sample_alias,sample_description,first_public,country,scientific_name,fastq_bytes,base_count,read_count,library_name,library_strategy,library_source,library_layout,instrument_platform,instrument_model,study_title,fastq_ftp', 'result': 'read_run'}: 500 Server Error: Internal Server Error for url: https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJNA313294&fields=run_accession%2Csample_accession%2Csample_alias%2Csample_description%2Cfirst_public%2Ccountry%2Cscientific_name%2Cfastq_bytes%2Cbase_count%2Cread_count%2Clibrary_name%2Clibrary_strategy%2Clibrary_source%2Clibrary_layout%2Cinstrument_platform%2Cinstrument_model%2Cstudy_title%2Cfastq_ftp&result=read_run
```
Use only chromosome 22 instead of the whole human genome
*To do this, I have replaced the whole T2T genome accession `GCF_009914755.1` with the Chr22 accession `NC_060948.1` and the NAME= to `HsapiensT2T_chr22`.*
*This messes up the annotation target because Chr22 does not individually have its own annotation files. Therefore I added a new variable `ANNOT_ACC=${ACC}` that is the same as ACC by default, but can be changed to accommodate a different annotatio accession, which in this case will still be the whole T2T genome.*
*This now runs much faster, just over a minute on my computer.*

Change `.zip` file extension to `.fa.gz`
*Here I changed the REF= from `REF=refs/${NAME}.zip` to `REF=refs/${NAME}.fa.gz`.*


### Overview
This readme describes how to use this directory's Makefile to 1) download a reference fasta from NCBI and its annotations, and index it and 2) download fastq reads from SRR runs dictated in a design.csv file, run fastqc on those reads, align them to the reference, generate wiggle files, and generate alignment stats in parallel using GNU parallel. 

First, we will collect SRA metadata in a csv format, then run `make ref` to download the reference, and then run a paralelized version of `make reads` to do the rest.

I am using Bioproject `PRJNA313294` from the paper [Tang et al., 2016](https://pmc.ncbi.nlm.nih.gov/articles/PMC5299540/) which collected RNAseq data from human cortical neural precursor cells infected with Zika virus.

### Makefile usage
```
    # Makefile for aligning reads from SRA to a genome from NCBI with BWA, and making wiggle file for visualization"
	# Input variables: 
    ## Genome accession=${ACC}
    ## Interpretable reference name=${NAME}
    ## Annotation file types=${ANNOT} 
    ### (options are: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report), 
    ## SRA accession=${SRR} 
    ## Number of reads=${N}
	# Usage: make [all|ref|reads|fasta|annotations|index|fastq|fastqc|align|stats|wiggle|clean]"
	## make all will run all steps sequentially.
    ## make ref will download and index the reference genome and annotations.
    ## make reads will download, quality check, align the reads, generate stats, and make wiggle files.
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
make ref ACC=NC_060948.1 NAME=HsapiensT2T_Chr22 ANNOT_ACC=GCF_009914755.1 ANNOT=gff3,gtf
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

### Revision Results
This runs much faster! Few reads map tp Chr22, but I'm only pulling 1,000 (x2) reads from the whole genome so this is not surprising. Having everything run smooth in less than 5 minutes is a big improvement.
