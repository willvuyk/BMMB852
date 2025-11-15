# Week 12 Assignment: Compare sequencing tech in Cancer Genome in a Bottle study
## Will Vuyk • BMMB852 • 2025-11-15

## Overview
The purpose of this assignment is to compare multiple different sequencing technologies used in the Cancer Genome in a Bottle Project, which sequenced the genome of cancer cells with Illumina, Element, Pacbio, and ONT technologies.

## Determine region of interest:
p53 (gene TP53) is known as the "guardian of the genome" and mutations in it are related to cancer. 

The gene TP53 is found on chromosome 17 around position 7.6 million. I therefore have decided to test the different sequencing technologies on the 7 to 8 million bp region of chromosome 17. 

While I do not do variant analysis in this assignment, looking at variant calls in the TP53 gene would be an interesting thing to do in the future.

## Run

To download the reference genome run:

```
make ref
```

To download, generate bigwig files, and run samtools stat on the bam files listed in the design.csv file, run:

```
cat design.csv | parallel --colsep , --header : --eta --lb -j 3 make bam TECH={tech} BAM_URL={url}
```

## Results
Here are the results (summarized in table format manually from samtools stat output) ordered by total read number.

| Technology       | Total Reads | Total Reads Mapped | Percent Reads Mapped | Average Error Rate (Cigar) | Average Quality | Average Length | Maximum Length |
|------------------|-------------|---------------------|------------------------|-----------------------------|------------------|-----------------|-----------------|
| Illumina NovaSeq | 739208      | 736638              | 0.996523306            | 6.30E-03                    | 35               | 151             | 151             |
| Pacbio Onso      | 560404      | 550252              | 0.981884498            | 2.75E-03                    | 49.7             | 140             | 150             |
| Element Aviti    | 332174      | 330342              | 0.994484818            | 4.25E-03                    | 48.3             | 148             | 150             |
| ONT STD          | 11792       | 11792               | 1                      | 3.32E-02                    | 35.4             | 9212            | 561491          |
| Pacbio Revio     | 2724        | 2724                | 1                      | 7.15E-03                    | 37.6             | 17610           | 44769           |
| ONT UL           | 703         | 703                 | 1                      | 2.28E-02                    | 41               | 39085           | 597585          |

Important clarification I had to look up: Cigar Error Rate is the number of bases mismatched to the reference / total bases mapped. This includes what could be "true" mutations or differences in the aligned sequences. Quality, on the other hand, is a metric of sequencing error, or errors between the sequence and the molecule that was sequenced. 

Some stats that stand out to me are the 1) high average quality scores of the PacBio Onso and Element Aviti 2) the very long reads of ONT UL. The fact ONT UL has a higher average quality than Illumina Novaseq and PacBio Revio strikes me as odd here, as ONT is generally considered to have lower sequence quality. 


## Visualization in IGV

Here is an image of all the bigwig files aligned with each other

[bigwig](bigwig.png)

Illumina NovaSeq appears to have the best coverage depth accross the region of all short read platforms. ONT STD appears to have the best coverage depth for long-read platforms. 





