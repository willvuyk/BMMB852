# Week 2 Assignment: Demonstrate data analysis at unix command line
## Will Vuyk • BMMB852 • 2025-09-06

### 1) Organize your working directory
To replicate this analysis, first define the path to your working directory. Mine is called "852_005_UnixDataAnalysis". Fill in YOURPATH below:

```
DIR=YOURPATH/02_UnixDataAnalysis
```

Make your working directory at that path ***if it does not already exist*** using `mkdir`

```
mkdir -p $DIR
```

Next, move into that new working directory using cd

```
cd $DIR
```


### 2) Download and unzip a GFF3 file from Ensemble

Once in your working directory, define the GFF3 file you want to download from [Ensemble Public FTP site](http://ftp.ensembl.org/pub/current_gff3/) and the link to that file. 

Remove the .gz from your filename so it ends in `gff3`. Your link, on the other hand, should be complete.

```
GFF=Sus_scrofa.Sscrofa11.1.115.chr.gff3
GFF_LINK=http://ftp.ensembl.org/pub/current_gff3/sus_scrofa/Sus_scrofa.Sscrofa11.1.115.chr.gff3.gz
```

Use the unix command `wget` to download the GFF3 file

```
wget $GFF_LINK
```

I chose to download the GFF3 file for the organism Sus scrofa. 

Sus scrofa is the latin name for the eurasian wild pig, or wild boar, as well as all domesticated pigs. 

This particular GFF3 file is for the genome assembly Sscrofa11.1, which is a recent PacBio assembly of the domestic duroc breed genome by the Swine Genome Sequencing Consortium.

I chose to download the chr.gff3.gz file, not the gff3.gz file, to avoid unplaced scaffolds and contigs for simplicity.

Assess downloaded file size and compression using `ls`

```
ls -lh
```

Unzip compressed GFF file using `gunzip`. This is why we removed the .gz from the filename above when defining the GFF variable above.

```
gunzip $GFF.gz
```

Check that the file is unzipped using `ls`

```
ls -lh   
```


### 3) Analyze the GFF file using unix commands

Print first 10 lines of GFF file to the screen using `head` for a first look

```
cat $GFF | head
```

Can also look at the last 10 lines using `tail`

```
cat $GFF | tail
```

To view more of the file on your screen, use the following:

```
cat $GFF | more
```

### 4) Count and characterize the number of sequence regions the file contains

Extract lines containing the string "sequence-region" using `grep` and add them to new text file called sequence_regions.txt

```
cat $GFF | grep "sequence-region" > chr_sequence_regions.txt
```

For Sus scrofa, the sequence_regions.txt file lists 18 autosomes (non-sex chromosomes) labeled 1-18, 2 sex chromosomes (X and Y), and one mitochondrial organelle genome (MT). 

This aligns with what I would generally expect for a placental mammal, and is indeed what is listed for this assembly on [NCBI](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000003025.6/)

If I had instead used the full gff3 file (ie not the chr.gff3 file), I would have seen many more sequence regions listed, as that file includes unplaced scaffolds and contigs. NCBI lists 705 scaffolds and 1117 contigs. 

### 5) Count, sort, and rank all unique features in the GFF file

To count the total number of features in a GFF file, count the number of lines that are not comments (comments start with a # character).

Use `grep -v` to exclude comment lines, and `wc -l` to count the number of lines

```
cat $GFF | grep -v "^#" | wc -l > chr_features_count.txt
```

For Sus scrofa, the result here is 1406065, meaning there are 1,406,065 features annotated in this GFF file.

```
cat $GFF | cut -f 3 | grep -v "^#" | sort-uniq-count-rank > chr_features_ranked.txt
```
The line above is the equivalent of running ` sort | uniq -c | sort -r ` on the output of `cut -f 3` which extracts column 3 (the feature type) from the GFF file. `grep -v "^#"` is used to exclude comment lines.

Use the option below to just get the top 10 most annotated features

```
cat $GFF | cut -f 3 | grep -v "^#" | sort-uniq-count-rank | head > chr_features_top10.txt
```

The top 10 features for the Sus scrofa chr file are exon, CDS, biological_region, five_prime_UTR, three_prime_UTR, mRNA, gene, ncRNA_gene, lnc_RNA, snRNA

Sum the number of features listed in the features.txt file to double check the total number of features

```
cat features_ranked.txt | awk '{sum += $1} END {print sum}' > chr_features_ranked_sum.txt
```

Again, for Sus scrofa, the result here is 1406065, which matches the previous total feature count.

### 6) Confirming results with NCBI

According to the features.txt file, there are ***20963 genes*** in the Sus scrofa GFF file I have used. 

NCBI lists 27,250 genes for this assembly, which is higher. This may be because the GFF file I used is only for chromosomes, and does not include unplaced scaffolds and contigs, which may contain additional genes.

To test this, I will download the full gff3 file and repeat the analysis.

```
GFF_ALL=Sus_scrofa.Sscrofa11.1.115.gff3
GFF_ALL_LINK=http://ftp.ensembl.org/pub/current_gff3/sus_scrofa/Sus_scrofa.Sscrofa11.1.115.gff3.gz
wget $GFF_ALL_LINK
gunzip $GFF_ALL.gz
cat $GFF_ALL | grep -v "^#" | wc -l > all_features_count.txt
cat $GFF_ALL | cut -f 3 | grep -v "^#" | sort-uniq-count-rank > all_features_ranked.txt
cat all_features_ranked.txt | awk '{sum += $1} END {print sum}' > all_features_ranked_sum.txt
```
While the numbers in the `all_features_ranked.txt` file are larger, they are still smaller than what is listed on NCBI. Maybe NCBI is using some other way to calculate feature number? I know there are predictive ways to do this, as done in the abbinitio files on ensembl. I will ask about this in class.


### Conclusions
Having looked at the Sscrofa11.1 GFF3 file, it does appear that the domesticated pig is a well-annotated organism. This makes sense due to its importance in agriculture and medicine. 

I learned it is very important to know exactly what GFF file you are using, be it the full gff, chr gff, or other type like the abbinitio type. Even for a well-annotated organism like Sus scrofa, exactly how annotations are calculated and defined can make a significant different in interpretation.
