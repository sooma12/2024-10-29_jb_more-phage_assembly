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

echo "Fastq input files in $FASTQ_INPUTS"
echo "Writing fastqc outputs to $OUT_DIR"
echo "Scripts in $SCRIPT_DIR"

mkdir -p $FASTQ_INPUTS $OUT_DIR $SCRIPT_DIR

echo "Running fastqc in directory $FASTQ_INPUTS"
fastqc $FASTQ_INPUTS/*.fastq.gz

echo "Cleaning up logs and output files"
mv $SCRIPT_DIR/fastq_breseq_* $SCRIPT_DIR/logs
mkdir -p $OUT_DIR/fastqc_html $OUT_DIR/fastqc_zip
mv $FASTQ_INPUTS/*fastqc.html $OUT_DIR/fastqc_html
mv $FASTQ_INPUTS/*fastqc.zip $OUT_DIR/fastqc_zip



