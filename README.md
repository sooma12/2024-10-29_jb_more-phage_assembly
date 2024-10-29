# 2024-10-29_jb_more-phage_assembly



*below copied from 10/21/24 readme*



## Library prep

From Seqcenter:

```text
Illumina sequencing libraries were prepared using the tagmentation-based and PCR-based
Illumina DNA Prep kit and custom IDT 10bp unique dual indices (UDI) with a target insert size of
280 bp. No additional DNA fragmentation or size selection steps were performed. Illumina
sequencing was performed on an Illumina NovaSeq X Plus sequencer in one or more multiplexed
shared-flow-cell runs, producing 2x151bp paired-end reads. Demultiplexing, quality control and
adapter trimming was performed with bcl-convert1 (v4.2.4). Sequencing statistics are included in
the ‘DNA Sequencing Stats.xlsx’ file.
```

## Samples

Input from EG:

`/work/geisingerlab/SEQCENTER-SEQUENCINGREADS-BACKUP/20230707_IlluminaDNAReads_JBphi9_15/
phage_9
phage_15A
phage_15B
phage_15C`

`/work/geisingerlab/SEQCENTER-SEQUENCINGREADS-BACKUP/20230828_SeqCenter_IlluminaDNAReads_JBphi_bulk/
bulk1
bulk2
bulk7`


Made links to these files in ./input/fastq_raw

```bash
cd ${BASE_DIR}/input/fastq_raw
find /work/geisingerlab/SEQCENTER-SEQUENCINGREADS-BACKUP/20230707_IlluminaDNAReads_JBphi9_15/ -name "phage*" >>fastq_inputs.list
find /work/geisingerlab/SEQCENTER-SEQUENCINGREADS-BACKUP/20230828_SeqCenter_IlluminaDNAReads_JBphi_bulk/ -name "bulk*" >>fastq_inputs.list 

cat fastq_inputs.list

paste fastq_inputs.list | while read file;
do
ln -s $file ./
done

```

## fastqc
First run using script 0

## bbduk
Per assembly protocol from Eddie (provided by collaborators?), ran bbduk to remove phix.  This resulted in 0 dropped reads, so there are no contaminants.  Therefore, went back to original files and performed quality trimming per their recommendations.

Options:
ref=/bioinformatics/bbmap/resources/adapters.fa ktrim=r tpe tbo minlen=100
qtrim=rl trimq=28

## Subsampling?

```text
for file in ./*.fastq.gz; do
> echo $(zcat $file | wc -l )/4 | bc
> done

```

Per protocol, 
"Excessive coverage can be detrimental to genome assembly and result in the generation of spurious contigs, homopolymer and indel errors. Most de Bruijn assemblers work best between 60-100x coverage."

Number of reads = (Expected coverage * Expected genome size in bp) / Read length in bp

Read length = 151
Use expected coverage = 100
Per EG, expect ~43 kb genome.

Num.reads = 100 coverage * 43,000 bp / 151 bp = 28477 reads

Ran following code:

```bash
module load seqtk/1.3
cd /work/geisingerlab/Mark/genome_assembly/2024-10-29_jb_more-phage_assembly/input/fastq_trimmed

mkdir -p ../fastq_subsamples

for file in ./*.fastq.gz; do
  filename=$(basename $file)
  seqtk sample -s 100 $file 28500 > ../fastq_subsamples/28-5k_subsample_${filename}
done

```


## Assembly

Assembled using SPAdes with suggested parameters:

spades.py --careful -t 8 -m 12 -k 55,77,99,127 -1 $r1 -2 $r2 -o ./spades_assembly/$name

Go into spades_assembly directory and count contigs and scaffolds:

```bash
for dir in ./*; do echo $dir; echo 'contigs:'; grep -c '>' $dir/contigs.fasta; echo 'scaffolds:'; grep -c '>' $dir/scaffolds.fasta; done
```

```text

```


```bash
# Recommendation for filtering contigs
seqkit fx2tab contigs.fasta | csvtk mutate -H -t -f 1 -p "cov_(.+)" | csvtk
mutate -H -t -f 1 -p "length_([0-9]+)" | awk -F "\t" '$4>=10 && $5>=500' | seqkit
tab2fx > filtered_contigs.fasta

```

## Mapping reads back to assembly

Script 3

Note, bbmap initially threw an error saying that the subsample .fastq.gz files were not gzipped

Tried gunzipping these files and got an error that they were not actually gzipped?!

I copied the subsamples in input/fastq_subsamples to a subfolder input/fastq_subsamples/2024-10-22_gzips/

Then removed .gz extensions from subsample .fastq.gz files

## Annotation

Pharokka
https://academic.oup.com/bioinformatics/article/39/1/btac776/6858464

George Bouras, Roshan Nepal, Ghais Houtak, Alkis James Psaltis, Peter-John Wormald, Sarah Vreugde, Pharokka: a fast scalable bacteriophage annotation tool, Bioinformatics, Volume 39, Issue 1, January 2023, btac776, https://doi.org/10.1093/bioinformatics/btac776.

If you use pharokka, please see the full Citation section for a list of all programs pharokka uses, in order to fully recognise the creators of these tools for their work.

