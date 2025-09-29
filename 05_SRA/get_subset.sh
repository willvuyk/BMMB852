#!/bin/bash 

# Set the trace to show the commands as executed
set -uex

# ------ Defining command line inputs --------

# SRR accession
SRR=$1

# number of reads to download
NREADS=$2

# output directory
OUTDIR=$3

# ------ NO Changes below this line --------

# Download a subset of reads based on command line inputs.
mkdir -p $OUTDIR
fastq-dump -X $NREADS -F --outdir $OUTDIR --split-files $SRR

# Completion message
echo "Downloaded at most $NREADS reads from $SRR to $OUTDIR"
echo "Script complete"

# End of script
