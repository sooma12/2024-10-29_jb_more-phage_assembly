#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=map_reads
#SBATCH --time=04:00:00
#SBATCH --array=1-4%5
#SBATCH --ntasks=4
#SBATCH --mem=100G
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.log
#SBATCH --error=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=soo.m@northeastern.edu

# Performs the following:

source ./config.cfg
# For loading bbmap
module load OpenJDK/19.0.1
export PATH=$PATH:/work/geisingerlab/Mark/software/bbmap/

mkdir -p $MAP_DIR/covstats $MAP_DIR/mapped_sam $MAP_DIR/mapped_bam $MAP_DIR/stats $MAP_DIR/unmapped

# Get directory name of sample for this array node
sample=$(find $SPADES_DIR -maxdepth 1 -mindepth 1 -type d | sort | head -n "$SLURM_ARRAY_TASK_ID" | awk -F/ '{print $NF}' | tail -n 1)

# Get contigs.fa file for this array node.  Copy to MAP_DIR, renaming them to phage name as well.
sample_contigs=${sample}_contigs.fasta
cp $SPADES_DIR/$sample/contigs.fasta $MAP_DIR/$sample_contigs
# $MAP_DIR/$sample_contigs is the contig file to work on.

subsample_R1=$(find $BASE_DIR/input/fastq_subsamples -maxdepth 1 -mindepth 1 | grep $sample | grep "R1")
subsample_R2=$(find $BASE_DIR/input/fastq_subsamples -maxdepth 1 -mindepth 1 | grep $sample | grep "R2")

# UNNECESSARY? unzip the fastq files?? gunzip.
gunzip $subsample_R1
gunzip $subsample_R2

# rum BBMap
bbmap.sh ref=$MAP_DIR/$sample_contigs in1=$subsample_R1 in2=$subsample_R2 covstats=$MAP_DIR/covstats/${sample}_contig_covstats.txt out=$MAP_DIR/mapped_sam/${sample}_contig.mapped.sam

# UNNECESSARY? compress the fastq files??
# $ gzip ../illumina_reads/phage.nophix.clean.R1.fastq.gz
# ../illumina_reads/phage.nophix.clean.R2.fastq.gz

# Load samtools
module load samtools/1.19.2
# SAM to BAM and index
samtools view -bS -F4 $MAP_DIR/mapped_sam/${sample}_contig.mapped.sam | samtools sort - -o $MAP_DIR/mapped_bam/${sample}_contig.mapped.sorted.bam
samtools index $MAP_DIR/mapped_bam/${sample}_contig.mapped.sorted.bam

# samtools stats
samtools flagstat $MAP_DIR/mapped_bam/${sample}_contig.mapped.sorted.bam > $MAP_DIR/stats/${sample}_mapping_stats.txt

# collect unmapped reads
samtools view -bS -f4 $MAP_DIR/mapped_sam/${sample}_contig.mapped.sam | samtools sort - -o $MAP_DIR/unmapped/${sample}_unmapped_reads.bam
