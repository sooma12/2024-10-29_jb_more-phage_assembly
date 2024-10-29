#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=bbduk-kqtrim
#SBATCH --time=04:00:00
#SBATCH --array=1-4%5
#SBATCH --ntasks=4
#SBATCH --mem=100G
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.log
#SBATCH --error=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=soo.m@northeastern.edu

# Load config file
source ./config.cfg

# Load java
module load OpenJDK/19.0.1

export PATH=$PATH:/work/geisingerlab/Mark/software/bbmap/

echo "sample sheet located at $SAMPLE_SHEET_BBDUK"

mkdir -p $TRIMMED_FQ

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $SAMPLE_SHEET_BBDUK |  awk '{print $1}')
r1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $SAMPLE_SHEET_BBDUK |  awk '{print $2}')
r2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $SAMPLE_SHEET_BBDUK |  awk '{print $3}')

bbduk.sh in1=$r1 in2=$r2 \
out1=${BASE_DIR}/input/fastq_trimmed/${name}_trimmed_R1.fastq.gz out2=${BASE_DIR}/input/fastq_trimmed/${name}_trimmed_R2.fastq.gz \
ref=${ADAPTERS} \
ktrim=r \
tpe \
tbo \
minlen=100 \
qtrim=rl \
trimq=28 \
stats=${BASE_DIR}/logs/${name}_trimming_stats.txt


