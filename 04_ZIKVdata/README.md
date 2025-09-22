# Week 4 Assignment: Obtain genomic data via accession numbers
## Will Vuyk • BMMB852 • 2025-09-21

### 1) Identify accession numbers
The GEO accession number for RNAseq expression data has already been pulled out on the course web page. It is `GSE78711`. It can be found in the paper after the "Acknowledgements" section, under a section titled "Accession Numbers".

The course website explains that only the expression data is located in GEO, while the sequence data is located in SRA. The associated SRA bioproject is `PRJNA313294`. This was done using the following code from the course website:

```
# Crosslink to sra.
esearch -db gds -query GSE78711 | elink -target sra | \
                       efetch -format runinfo > runinfo.csv

# Get the SRR run IDs for the data
cat runinfo.csv | cut -f 1,22 -d , | head
```

The file generated here is much larger than I would have expected, and contains sra accession numbers not related to the project. This confuses me, but moving on. 

### 2) Download data
#### 2.1) Download reference
There do not appear to be annotations that are viewable in IGV. The RNAseq counts appear to be in csv format. I will download and align the fasta files. 


Activate bioinfo environment

```
micromamba activate bioinfo
```

Make subdirectory for NCBI reference files and move there.

```
mkdir -p ncbi_ref

cd ncbi_ref
```

Define reference genome. In this case I am using `GCF_009914755.1` which is the Human Telomere to Telomere genome mentioned in class. While the paper for group two is a study about ZIKV, the RNAseq reads are from human hNPC cells. 

```
ref=GCF_009914755.1
```

Download reference fasta and GFF files using NCBI datasets into ncbi_ref subdirectory.

```
datasets download genome accession $ref \
         --include genome,gff3,gtf 
```

Unzip into ncbi_ref subdirectory using `unzip`

```
unzip ncbi_dataset.zip
```


#### 2.2) Download paper results
Define SRA bioproject where paper reads are located. In this case (as mentioned above) this is `PRJNA313294`.

```
bioproj=PRJNA313294 
```

Use `efetch` to create SRA accession list (accession.txt) from defined bioproject.

```
esearch -db bioproject -query $bioproj | \
elink -target sra | \
efetch -format runinfo | \
cut -d ',' -f1 | sed 1d > accession.txt
```

Use SRA `prefetch` to download all accessions in accession.txt, then convert to FASTQ using `fasterq-dump`.

```
# Download all SRR accessions listed in accession.txt
prefetch --option-file accession.txt

# Convert each SRA file to FASTQ
while read SRR; do
  fasterq-dump $SRR
done < accession.txt
```

#### The next step here would be to align all of these fastqs using the reference into a BAM file to vizualize in IGV, but I think that is outside the scope of this homework. 

#### Moving forward now with only the reference fasta and GFF files to answer the homework questions.

### 3) Looking at FASTA and GFF files in IGV

#### Notice: My IGV will not load the T2T genome. I do not know why. The following questions are answered without IGV.

#### How big is the genome, and how many features of each type does the GFF file contain? 
The genome is 3.1gb long (according to NCBI website). 

Using sort-uniq-count-rank to create a ranked file of GFF features.

```
GFF=ncbi_dataset/data/GCF_009914755.1/genomic.gff

cat $GFF | cut -f 3 | grep -v "^#" | sort-uniq-count-rank > features_ranked.txt
```

Here are the ranked feature results:
```
2147966	exon
1678264	CDS
272975	cDNA_match
149196	match
130539	mRNA
127873	biological_region
107042	enhancer
41561	gene
34197	silencer
31856	lnc_RNA
17002	pseudogene
13702	transcript
2843	miRNA
2030	transcriptional_cis_regulatory_region
1889	primary_transcript
1245	protein_binding_site
1190	snoRNA
753	rRNA
521	tRNA
428	nucleotide_motif
427	non_allelic_homologous_recombination_region
425	V_gene_segment
400	recombination_feature
374	promoter
277	sequence_feature
259	meiotic_recombination_region
174	mobile_genetic_element
168	DNaseI_hypersensitive_site
146	snRNA
105	conserved_region
105	J_gene_segment
92	CAGE_cluster
79	origin_of_replication
58	tandem_repeat
55	repeat_instability_region
54	mitotic_recombination_region
49	enhancer_blocking_element
49	scaRNA
41	antisense_RNA
32	D_gene_segment
30	sequence_alteration
29	TATA_box
28	C_gene_segment
28	region
19	response_element
18	chromosome_breakpoint
17	sequence_secondary_structure
14	locus_control_region
14	matrix_attachment_site
12	epigenetically_modified_region
11	direct_repeat
11	replication_regulatory_region
9	insulator
9	minisatellite
6	repeat_region
5	CAAT_signal
5	dispersed_repeat
5	microsatellite
4	inverted_repeat
4	nucleotide_cleavage_site
4	scRNA
4	sequence_comparison
4	vault_RNA
4	Y_RNA
3	GC_rich_promoter_region
3	replication_start_site
1	imprinting_control_region
1	regulatory_region
1	RNase_MRP_RNA
1	RNase_P_RNA
1	telomerase_RNA
```


#### What is the longest gene? What is its name and function? 
*You may need to search other resources to answer this question. Look at other gene names. Pick another gene and describe its name and function.*
The longest known human gene is the dystrophin gene. This appears to be from the article:

```
Tennyson, C., Klamut, H. & Worton, R. The human dystrophin gene requires 16 hours to be transcribed and is cotranscriptionally spliced. Nat Genet 9, 184–190 (1995). https://doi.org/10.1038/ng0295-184
```
Another human gene is the Huntingtin gene, which is located on chromosome 4 and codes for the huntingtin protein. This protein, and its length, is linked to Huntington's Disease, which is an autosomal dominant neurodegenerative disease.

#### Look at the genomic features, are these closely packed, is there a lot of intragenomic space? Using IGV estimate how much of the genome is covered by coding sequences.
Since IGV is not working for me, I looked this up online. The textbook chapter linked below says that ~1% of the human genome is protein coding

(RNA, the Epicenter of Genetic Information: A new understanding of molecular biology. Chapter 11: The Human Genome)[https://www.ncbi.nlm.nih.gov/books/NBK595930/]

#### Find alternative genome builds that could be used to perhaps answer a different question (find their accession numbers). Considering the focus of the paper, think about what other questions you could answer if you used a different genome build.

The paper mentions a knowledge gap about how it is unknown how other ZIKV strains may behave differently. Another knowledge gap may be that different hNPC cells could respond differently to ZIKV infection. Comparing the hNPC transcripts to other human genomes from diverse populations could be an interesting way to initially assess this.

Some example accession numbers include:
GCA_000001405.29
GCA_018873775.2
GCA_011064465.2
GCA_000306695.2
