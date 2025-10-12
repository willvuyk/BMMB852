#
# Makefile for aligning short reads with BWA
# Edited from [Biostar Handbook](https://www.biostarhandbook.com/fast/methods/makefiles/)
#

# Real Read Alignment Variables
# NCBI Genome accession number  
ACC=GCF_009914755.1

# The user-friendly name for the genome
NAME=HsapiensT2T

# Define the annotation file types to download separated by comma
# Options include: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report
ANNOT=gff3,gtf

# SRR number
SRR=SRR3191544

# How many reads to download
N=10000000

# Reference genome
REF=refs/${NAME}.zip

# Read 1
R1=reads/${SRR}_1.fastq

# Read 2
R2=reads/${SRR}_2.fastq

# BAM file
BAM=bam/${SRR}.bam

# The temporary bedgraph file
BG=bam/${SRR}.bedgraph

# The BW wiggle file
BW=bam/${SRR}.bw


# Setting useful defaults.
# Set the shell the commands run in.
SHELL = /bin/bash
# Execute all commands in a single shell.
.ONESHELL:
# Run the shell with strict error checking.
.SHELLFLAGS = -eu -o pipefail -c
# Delete target files if the command fails.
.DELETE_ON_ERROR:
# Warn about undefined variables.
MAKEFLAGS += --warn-undefined-variables
# Disable built-in rules.
MAKEFLAGS += --no-builtin-rules

# Prints the usage message
usage:
	@echo "#"
	@echo "# Makefile for aligning reads from SRA to a genome from NCBI genomes with BWA, and making wiggle file for visualization"
	@echo "# Input variables: Genome accession=${ACC}, Interpretable reference name=${NAME}, annotation file types=${ANNOT} (options are: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report), SRA accession=${SRR}, number of reads=${N}"
	@echo "# Usage: make [all|refs|annotations|fastq|index|align|stats|wiggle|clean]"    
	@echo "#"

# Obtain the reference genome (if not already done)
refs:
	@echo "# Create the reference directory"
	@echo "# I am extracting the directory name from the path"
	mkdir -p $(dir ${REF})

	@echo "# Download the reference genome"
	bio fetch ${ACC} --format fasta > ${REF}

	@echo "# Create stats directory if it does not already exist"
	mkdir -p stats

	@echo "# Create file with some information about the genome"
	seqkit stats ${REF} > stats/${NAME}_fasta_stats.txt
	
	@echo "# Print stats in terminal"
	cat stats/${NAME}_fasta_stats.txt

# Obtain the reference annotations (if not already done)
annotations:
	@echo "# Download the reference annotations"
	datasets download genome accession ${ACC} --include ${ANNOT} 

	@echo "# Unzip the downloaded file, skipping existing files"
	unzip -n ncbi_dataset.zip

	@echo "# Move the downloaded files to the annotations directory"
	mv ncbi_dataset ${NAME}_annotations

# Download a subset of reads from SRA
# Remove the -X flag to get all data.
fastq:
	@echo "# Create the reads directory"
	mkdir -p $(dir ${R1})

	@echo "# Download the reads"
	fastq-dump -X ${N} --outdir reads --split-files ${SRR}

	@echo "# Create stats directory if it does not already exist"
	mkdir -p stats

	@if [ -f "${R2}" ]; then \
		echo "# Stats on paired reads"; \
		seqkit stats ${R1} ${R2} > stats/${SRR}_fastq_stats.txt; \
	else \
		echo "# Stats on single reads"; \
		seqkit stats ${R1} > stats/${SRR}_fastq_stats.txt; \
	fi
	
	@echo "# Print stats in terminal"
	cat stats/${SRR}_fastq_stats.txt

# Index the reference genome
index:
	bwa index ${REF}

# Align the reads and convert to BAM. Use 4 threads
# Works for paired-end reads. Modify for single-end reads.
align:
	@echo "# Make the BAM directory"
	mkdir -p $(dir ${BAM})

	@if [ -f "${R2}" ]; then \
		echo "# aligning paired reads"; \
		bwa mem -t 4 ${REF} ${R1} ${R2} | samtools sort  > ${BAM}; \
	else \
		echo "# aligning single reads"; \
		bwa mem -t 4 ${REF} ${R1} | samtools sort  > ${BAM}; \
	fi

	@echo "# Index the BAM file"
	samtools index ${BAM}

# Generate alignment statistics
stats:
	@echo "# Create stats directory if it does not already exist"
	mkdir -p stats	
	
	@echo "# Generate alignment statistics"
	samtools flagstat ${BAM} > stats/${SRR}_bam_flagstat.txt
	
	@echo "# Print stats in terminal"
	cat stats/${SRR}_bam_flagstat.txt

# Create wiggle files (bigwig) from the BAM file in BAM directory
wiggle:
	@echo "# Index the reference genome"
	samtools faidx ${REF}

	@echo "# Generate the temporary bedgraph file."
	LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | sort -k1,1 -k2,2n > ${BG}

	@echo "# Convert the bedgraph file to bigwig."
	bedGraphToBigWig ${BG} ${REF}.fai ${BW}

# Clean up generated files
clean:
	rm -rf ${REF} ${R1} ${R2} ${BAM} ${BAM}.bai

# Create necessary directories
all: refs annotations fastq index align stats wiggle

# Create necessary directories
.PHONY: all refs fastq index align clean stats annotations wiggle usage