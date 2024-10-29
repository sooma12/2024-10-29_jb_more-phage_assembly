#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=fastqc
#SBATCH --time=04:00:00
#SBATCH -N 1
#SBATCH -n 2
#SBATCH --output=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%j.output
#SBATCH --error=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%j.error
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=soo.m@northeastern.edu

echo "Starting fastqc SBATCH script $(date)"

echo "Loading environment and tools"
#fastqc requires OpenJDK/19.0.1
module load OpenJDK/19.0.1
module load fastqc/0.11.9

source ./config.cfg

echo "Fastq input files in $CLEANED_FASTQ_INPUTS"
echo "Writing fastqc outputs to $CLEANED_QC_OUT_DIR"
echo "Scripts in $SCRIPT_DIR"

mkdir -p $CLEANED_FASTQ_INPUTS $CLEANED_QC_OUT_DIR $SCRIPT_DIR

echo "Running fastqc in directory $CLEANED_FASTQ_INPUTS"
fastqc $CLEANED_FASTQ_INPUTS/*.fastq.gz

echo "Cleaning up logs and output files"
mv $SCRIPT_DIR/fastq_breseq_* $SCRIPT_DIR/logs
mkdir -p $CLEANED_QC_OUT_DIR/fastqc_html $CLEANED_QC_OUT_DIR/fastqc_zip
mv $CLEANED_FASTQ_INPUTS/*fastqc.html $CLEANED_QC_OUT_DIR/fastqc_html
mv $CLEANED_FASTQ_INPUTS/*fastqc.zip $CLEANED_QC_OUT_DIR/fastqc_zip



