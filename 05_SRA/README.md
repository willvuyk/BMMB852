# Week 5 Assignment: Obtain and visualize FASTQ data from SRA
## Will Vuyk • BMMB852 • 2025-09-28

### Write a bash script

#### Create a bash shell script with the code from last week.

The script is called `get_subset.sh` and is included in this directory. It is made to work with command line inputs, so script usage should look like this:

```
bash get_subset.sh [SRA accession] [number of reads] [name of output directory]
```

#### Briefly explain how you estimated the amount of data needed for 10x coverage.
This was more complicated than I expected. 

What is the length of the human transcriptome? What features even comprise the transcriptome? The closest I got to an answer was on this forum [seqanswers.com](https://www.seqanswers.com/forum/general/4437-size-of-human-transcriptome-exome-for-coverage-calculation). The people here defined the transcriptome as all annotated exons in a genome. Transcriptome length was then calculated for the human genome (Hg19) by counting all bases annotated as being part of an exon only once, as some bases are part of multiple exons. 

I don't know if this is the correct way to calculate the transcriptome length to assess RNAseq coverage for multiple reasons. First, different cells express different exons at varying levels, so the whole genome exome does not accuratley represent what RNAs an individual cell is transcribing. Second, if exons overlap, would not the transcribed (RNA) exome be longer than the DNA exome because bases that are a part of multiple exons only occur once on DNA, but on multiple RNAs. 

I think it is outside the scope of this assignment to pursue this further, so I will move forward with the estimate that the human transcriptome is roughly 80mB as calculated on [seqanswers.com](https://www.seqanswers.com/forum/general/4437-size-of-human-transcriptome-exome-for-coverage-calculation). 

To achieve 10x coverage of 80mB, 800mB are needed (10 x 80 = 800). 

Using `seqkit stats` on my chosen SRA file `SRR3191544_1.fastq` (from the Zika RNAseq paper) I see that the average read length is 75.4bp. This makes sense given the SRA page on NCBI for this accession says these are 50 cycle paired-end Miseq reads. I assume that the _1 in the file name indicates that these are all the read 1s (read 2s of the pair are in a separate file). With 50 cycles, there should be 50bp of sequence (if the molecule is longer than or equal to 50bp). The extra ~25bp should be the sequencing adaptors, and any other primers/adaptors that might be attached to the molecules from previous steps.

To calculate the number of reads, I divided 800,000,000 (800 mega bases) by 75.4 to get ~ 10610080 reads needed for roughly 10x coverage. 

#### Obtaining reads with `get_subset.sh`

This command obtains roughly 10x coverage of the human transcriptome from SRA accession SRR3191544.
```
bash get_subset.sh SRR3191544 10610080 subset_reads
```

### Quality assessment

#### Generate basic statistics on the downloaded reads (e.g., number of reads, total bases, average read length).

Using `seqkit stats` on both forward and reverse reads (1.fastq and 2.fastq files)

```
seqkit stats subset_reads/SRR3191544_1.fastq
seqkit stats subset_reads/SRR3191544_2.fastq
```
Output

```
file                             format  type   num_seqs      sum_len  min_len  avg_len  max_len
subset_reads/SRR3191544_1.fastq  FASTQ   DNA   7,361,527  555,374,256       35     75.4       76

file                             format  type   num_seqs      sum_len  min_len  avg_len  max_len
subset_reads/SRR3191544_2.fastq  FASTQ   DNA   7,361,527  555,388,034       35     75.4       76
```

It looks like these files don't contain enough reads to meet my 10x coverage threshold, so these are the complete files rather than a subset.


#### Run FASTQC on the downloaded data to generate a quality report.

Generating HTML quality reports with `fastqc`

```
fastqc subset_reads/SRR3191544_1.fastq
fastqc subset_reads/SRR3191544_2.fastq
```

#### Evaluate the FASTQC report and summarize your findings.

Sequence quality is high (all above Q32). The percent of Ns in each sequence looks to be effectively zero. The sequences are mostly right around 75bp long. One confusing thing is that the adapter content plot shows no adapters, but there is an adapter flagged in the overrepresented sequences table. I also expected adapter sequences to make up the difference between 50 cycles and 75 basepairs. Maybe fastqc can't identify the adapters used for some reason? 

### Compare sequencing platforms

I'm interested in what [Element Biosciences](https://www.elementbiosciences.com) "avidite sequencing" sequences look like in fastqc, so I will find an SRA accession sequenced using the platform "Element".

On the [SRA advanced search builder](https://www.ncbi.nlm.nih.gov/sra/advanced) I searched by "Platform" "element" and "Organism" "human". The first results to come up were RNA-seq - score!!

Selecting `SRR35514003` which is RNA-seq conducted on human colon cancer cells. The Element Aviti sequencer sequenced 75bp reads, which works well with my previous coverage calculation, so I will request the same number of reads as before: 10610080. 

Obtaining subset:

```
bash get_subset.sh SRR35514003 10610080 subset_element_reads
```

Fastqc

```
fastqc subset_element_reads/SRR35514003_1.fastq
```

The Element Aviti sequences have sequence quality error bars, not just a single number. These error bars range from Q28 to Q45, with the means clustering around 42, so these sequences do seem significantly more accurate. Average quality per read appears to be 43. All sequences are 75bp long extactly. There are no overrepresented sequences, yet fastqc is detecting low levels of Illumina adapters in the adapter sequence panel, which doesn't make much sense as these are not Illumina sequences.

Interesting! Average read quality above 40 is cool to see. 