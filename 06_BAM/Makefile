#
# Makefile for aligning short reads with BWA
# Edited from [Biostar Handbook](https://www.biostarhandbook.com/fast/methods/makefiles/)
#

# Real Read Alignment Variables
# NCBI Genome accession number  
ACC=GCF_009914755.1

# The user-friendly name for the genome
NAME=HsapiensT2T

# SRR number
SRR=SRR3191544

# How many reads to download
N=10000000

# Reference genome
REF=refs/${NAME}.fa

# Read 1
R1=reads/${SRR}_1.fastq

# Read 2
R2=reads/${SRR}_2.fastq

# BAM file
BAM=bam/${SRR}.bam


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
	@echo "# Makefile for aligning short reads from SRA to a genome from NCBI genomes with BWA"
	@echo "# Input variables: Genome accession=${ACC}, Interpretable reference name=${NAME}, SRA accession=${SRR}, number of reads=${N}"
	@echo "# Usage: make [all|refs|fastq|index|align|clean]"    
	@echo "#"

# Obtain the reference genome
refs:
	@echo "# Create the reference directory"
	@echo "# I am extracting the directory name from the path"
	mkdir -p $(dir ${REF})

	@echo "# Download the reference genome"
	bio fetch ${ACC} --format fasta > ${REF}

	@echo "# Create file with some information about the genome"
	seqkit stats ${REF} > ${NAME}_fasta_stats.txt
	
	@echo "# Print information in terminal"
	cat ${NAME}_stats.txt

# Download a subset of reads from SRA
# Remove the -X flag to get all data.
fastq:
	@echo "# Create the reads directory"
	mkdir -p $(dir ${R1})

	@echo "# Download the reads"
	fastq-dump -X ${N} --outdir reads --split-files ${SRR}

	@echo "# Show some information about the reads"
	seqkit stats ${R1} ${R2}

# Index the reference genome
index:
	bwa index ${REF}

# Align the reads and convert to BAM. Use 4 threads
# Works for paired-end reads. Modify for single-end reads.
align:
	@echo "# Make the BAM directory"
	mkdir -p $(dir ${BAM})

	@echo "# Align the reads"
	bwa mem -t 4 ${REF} ${R1} ${R2} | samtools sort  > ${BAM}

	@echo "# Index the BAM file"
	samtools index ${BAM}

# Generate alignment statistics
stats:
	samtools flagstat ${BAM} > ${SRR}_bam_flagstat.txt

# Clean up generated files
clean:
	rm -rf ${REF} ${R1} ${R2} ${BAM} ${BAM}.bai

# Create necessary directories
all: refs fastq index align stats

# Create necessary directories
.PHONY: all refs fastq index align clean stats