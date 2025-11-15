#
# Makefile for aligning short reads with BWA
# Edited from [Biostar Handbook](https://www.biostarhandbook.com/fast/methods/makefiles/)
#

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

#-------Variables-------

# Ref URL
REF_URL=https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/GRCh38/GRCh38_GIABv3_no_alt_analysis_set_maskedGRC_decoys_MAP2K3_KMT2C_KCNJ18.fasta.gz

# Ref file name
REF=ref/GRCh38.fasta.gz

# Define chromosome of interest
CHR=chr17

# Set the region of interest. Million bp around TP53 (~7.6mil)
REGION=chr17:7,000,000-8,000,000

# Set the URL of the BAM file
BAM_URL=

# Define sequencing tech
TECH=

# The BAM file name.
BAM=bam/${CHR}_${TECH}.bam

# define stats output file
STATS=stats/${CHR}_${TECH}_stats.txt

# .fai index file for BIGWIG
FAI=${REF}.fai

# The temporary bedgraph file
BG=wiggle/${TECH}.bedgraph

# The BW wiggle file
BW=wiggle/${TECH}.bw

#-------Do not edit below this line-------

usage:
	@echo "Usage:"
	@echo " # make ref                # Download and index the reference genome"
	@echo " # make bam TECH=<tech> BAM_URL=<bam_url>   # Download BAM file, extract region, index, generate bigwig and run samtools stats"


ref:
	@echo "# Create the reference directory"
	mkdir -p ref
	@echo "# Download the reference genome"
	curl -L ${REF_URL} > ${REF}
	@echo "# Index the reference genome for use with samtools."
	samtools faidx ${REF}
bam:
	@echo "# Create the BAM directory"
	mkdir -p bam
	@echo "# Create the stats directory"
	mkdir -p stats
	@echo "# Extract the reads for the region of interest."
	samtools view -b ${BAM_URL} ${REGION} > ${BAM}
	@echo "# Index the BAM file."
	samtools index ${BAM}
	@echo "# Get statistics on the BAM file."
	samtools stats ${BAM} > ${STATS}
	@echo "# Create wiggle directory if it does not already exist"
	mkdir -p wiggle	
	@echo "# Generate the temporary bedgraph file."
	LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | sort -k1,1 -k2,2n > ${BG}
	@echo "# Convert the bedgraph file to bigwig."
	bedGraphToBigWig ${BG} ${FAI} ${BW}

.PHONY: ref bam