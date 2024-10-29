#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=spades
#SBATCH --time=04:00:00
#SBATCH --array=1-4%5
#SBATCH --ntasks=4
#SBATCH --mem=100G
#SBATCH --cpus-per-task=8
#SBATCH --output=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.log
#SBATCH --error=/work/geisingerlab/Mark/genome_assembly/2024-10-21_jb_phage-assembly/logs/%x-%A-%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=soo.m@northeastern.edu

source ./config.cfg

sample_sheet=$SAMPLE_SHEET_SPADES
spades_dir=$SPADES_DIR

# SPAdes is in bioinformatics module
module load anaconda3/2021.11
source activate BINF-12-2021

echo "sample sheet located at $sample_sheet"

name=$(sed -n "$SLURM_ARRAY_TASK_ID"p $sample_sheet |  awk '{print $1}')
r1=$(sed -n "$SLURM_ARRAY_TASK_ID"p $sample_sheet |  awk '{print $2}')
r2=$(sed -n "$SLURM_ARRAY_TASK_ID"p $sample_sheet |  awk '{print $3}')

echo "assembling $name"

mkdir -p $spades_dir/$name

spades.py --careful -t 8 -m 12 -k 55,77,99,127 -1 $r1 -2 $r2 -o $spades_dir/$name
