#
# Makefile for aligning short reads with BWA
# Edited from [Biostar Handbook](https://www.biostarhandbook.com/fast/methods/makefiles/)
#

# Real Read Alignment Variables
# NCBI Genome accession number  
ACC=NC_060948.1

# The user-friendly name for the genome
NAME=HsapiensT2T_Chr22

# Define the annotation file types to download separated by comma
# Options include: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report
ANNOT=gff3,gtf
ANNOT_ACC=GCF_009914755.1
#Annotation file folder
ANN_DIR=${NAME}_annotations/

# SRR number
SRR=SRR3191544

# How many reads to download
N=100000

# Reference genome
REF=refs/${NAME}.fa

# Read 1
R1=reads/${SRR}_1.fastq

# Read 2
R2=reads/${SRR}_2.fastq

# Seqkit stats file
FASTASTATS=stats/${NAME}_fasta_stats.txt
FASTQSTATS=stats/${SRR}_fastq_stats.txt

# BAM file
BAM=bam/${SRR}.bam

#Flagstat file
BAMSTATS=stats/${SRR}_bam_flagstat.txt

# .fai index file for BIGWIG
FAI=${REF}.fai

# The temporary bedgraph file
BG=wiggle/${SRR}.bedgraph

# The BW wiggle file
BW=wiggle/${SRR}.bw

# VCF file

# The variant file
VCF = vcf/$(notdir $(basename ${BAM})).vcf.gz

# Additional bcf flags for pileup annotation.
PILE_FLAGS =  -d 100 --annotate 'INFO/AD,FORMAT/DP,FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/SP'

# Additional bcf flags for calling process.
CALL_FLAGS = --ploidy 1 --annotate 'FORMAT/GQ' 

# snpEFF variant prediction

# The GenBank annotation file.
WHOLEGFF = ncbi_dataset/data/${ANNOT_ACC}/genomic.gff
GFF = ${ANN_DIR}${NAME}.gff

# Annotated variants.
SNPEFF_ANN = snpEFF_ann/$(notdir $(basename ${VCF})).snpeff.vcf.gz

# The SNPeff html report.
SNPEFF_HTML = $(basename ${SNPEFF_ANN}).html

# The SNPeff CSV report.
SNPEFF_CSV = $(basename ${SNPEFF_ANN}).csv

# Where snpEff will store the database
IDX = idx/snpEff

# The SNPeff database.
SNPEFF_DB = ${IDX}/${NAME}/snpEffectPredictor.bin


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
	@echo "# Makefile for aligning reads from SRA to a genome from NCBI with BWA, and making wiggle file for visualization"
	@echo "# Input variables:""
	@echo "## Genome accession=${ACC}"
	@echo "## Accession for annotation file=${ANNOT_ACC}"
	@echo "## Interpretable reference name=${NAME}"
	@echo "## Annotation file types=${ANNOT}"
	@echo "### (options are: cds, gbff, genome, gff3, gtf, none, protein, rna, seq-report)"
	@echo "## SRA accession=${SRR}"
	@echo "## Number of reads=${N}"
	@echo "## VCF file=${VCF}"
	@echo "# Usage: make [all|ref|reads|fasta|annotations|index|fastq|fastqc|align|stats|wiggle|vcf|readsvcf|snpeff_build|snpeff_run|clean]"
	@echo "## make all will run all steps sequentially."
	@echo "## make ref will download and index the reference genome and annotations."
	@echo "## make reads will download, quality check, align the reads, generate stats, and make wiggle files."
	@echo "## make readsvcf will download, quality check, align the reads, generate stats, and make wiggle and vcf files."
	@echo "## make snpeff_build will build the snpEff database.
	@echo "## make snpeff_run will run snpEff to annotate the VCF file."

# Obtain the reference genome
fasta:
	@echo "# Create the reference directory"
	@mkdir -p $(dir ${REF})

	@echo "# Download the reference genome"
	@bio fetch ${ACC} --format fasta > ${REF}

	@echo "# Create stats directory if it does not already exist"
	@mkdir -p stats

	@echo "# Generate fasta stats"
	@seqkit stats ${REF} > ${FASTASTATS}

	@echo "# Print stats in terminal"
	@cat ${FASTASTATS}

# Index the reference genome
index:
	bwa index ${REF}
	samtools faidx ${REF}

# Obtain the reference annotations (if not already done)
annotations:
	@echo "# Create the annotations directory"
	@mkdir -p ${ANN_DIR}

	@echo "# Download the reference annotations"
	datasets download genome accession ${ANNOT_ACC} --include ${ANNOT} 

	@echo "# Unzip the downloaded file, skipping existing files"
	unzip -n ncbi_dataset.zip

	@echo "# Extract ACC from ANNOT_ACC"
	grep -w '${ACC}' ${WHOLEGFF} > ${GFF}

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
		seqkit stats ${R1} ${R2} > ${FASTQSTATS}; \
	else \
		echo "# Stats on single reads"; \
		seqkit stats ${R1} > ${FASTQSTATS}; \
	fi
	
	@echo "# Print stats in terminal"
	cat ${FASTQSTATS}

# Run fastqc
fastqc:
	@echo "# Create the fastqc directory"
	mkdir -p fastqc

	@echo "# Run FastQC on the reads"
	fastqc -o fastqc ${R1} ${R2}

	@echo "# FastQC reports are in the fastqc directory"

# Align the reads and convert to BAM. Use 4 threads
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
	samtools flagstat ${BAM} > ${BAMSTATS}
	
	@echo "# Print stats in terminal"
	cat ${BAMSTATS}

# Create wiggle files (bigwig) from the BAM file in BAM directory
wiggle:
	@echo "# Create wiggle directory if it does not already exist"
	mkdir -p wiggle	
	
	@echo "# Generate the temporary bedgraph file."
	LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | sort -k1,1 -k2,2n > ${BG}

	@echo "# Convert the bedgraph file to bigwig."
	bedGraphToBigWig ${BG} ${FAI} ${BW}

# Generate VCF
${VCF}: ${BAM} ${REF}
	mkdir -p $(dir $@)
	bcftools mpileup ${PILE_FLAGS} -O u -f ${REF} ${BAM} | \
		bcftools call ${CALL_FLAGS} -mv -O u | \
		bcftools norm -f ${REF} -d all -O u | \
		bcftools sort -O z > ${VCF}

${VCF}.tbi: ${VCF}
	bcftools index -t -f $<

vcf:: ${VCF}.tbi
	@ls -lh ${VCF}


# snpEFF

# Building a custom snpEff database snpeff needs the files in specific folders.
# 1. copy the files to their specific location.
# 2. append entry to current genome to the config.
# 3. Build the snpEff database.

${SNPEFF_DB}: ${GFF} ${REF}	
	mkdir -p ${IDX}/${NAME}

	# Copy the files to the snpEff folder.
	cp -f ${REF} ${IDX}/${NAME}/sequences.fa
	cp -f ${GFF} ${IDX}/${NAME}/genes.gff

	# Make the configuration file.
	echo "${NAME}.genome : ${NAME}" >	snpeff.config

	# Build the database.
	snpEff build -dataDir ${IDX} -v ${NAME}

# Create the annotated VCF file.
${SNPEFF_ANN} ${SNPEFF_HTML} ${SNPEFF_CSV}: 
	mkdir -p $(dir ${SNPEFF_ANN}) $(dir ${SNPEFF_HTML}) $(dir ${SNPEFF_CSV})
	snpEff ann \
	    -csvStats ${SNPEFF_CSV} \
		-s ${SNPEFF_HTML} \
		-dataDir ${IDX} \
		-v ${NAME} \
		${VCF} | bcftools view -O z -o ${SNPEFF_ANN}
	bcftools index ${SNPEFF_ANN}

# Creates the SNPeff database
snpeff_build: ${SNPEFF_DB}
	@ls -lh ${SNPEFF_DB}

# Another name for index
snpeff_index: build

# Removes the SNPeff database
snpeff_build!:
	rm -f ${SNPEFF_DB}

# Runs the SNPeff tool.
snpeff_run: ${SNPEFF_ANN} ${SNPEFF_HTML} ${SNPEFF_CSV}
	@ls -lh ${SNPEFF_ANN}
	@ls -lh ${SNPEFF_HTML}
	@ls -lh ${SNPEFF_CSV}

# Another name cleanup
snpeff_run!: clean

# Shows the usage information.
snpeff_install::
	@echo micromamba install snpeff


# Clean up generated files
clean:
	rm -rf ${REF} ${R1} ${R2} ${BAM} ${BAM}.bai ${ANN_VCF} ${ANN_HTML}

# Create necessary directories
all: fasta index annotations fastq fastqc align stats wiggle

ref: fasta index annotations

reads: fastq fastqc align stats wiggle

readsvcf: fastq fastqc align stats wiggle vcf

snpeff: snpeff_build snpeff_run

# Create necessary directories
.PHONY: all ref fasta annotations fastq fastqc index align clean stats wiggle usage vcf readsvcf snpeff_run snpeff_build snpeff_install