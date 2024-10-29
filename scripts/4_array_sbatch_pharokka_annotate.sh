#!/bin/bash
#SBATCH --partition=short
#SBATCH --job-name=pharokka_annot
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

# Load tools
echo "Loading environment and tools"
module load anaconda3/2021.05
eval "$(conda shell.bash hook)"
conda activate /work/geisingerlab/conda_env/pharokka
export PATH=$PATH:/work/geisingerlab/conda_env/pharokka/bin

mkdir -p $ANNOT_DIR/pharokka/input_contigs

# For this array, grab one sample name
one_fasta=$(find ./mapping/ -maxdepth 1 -mindepth 1 -name "*.fasta" | sort | head -n "$SLURM_ARRAY_TASK_ID" | tail -n 1)
sample=$(echo ${one_fasta} | awk -F/ '{print $NF}' | cut -f1,2 -d"_")

# Extract first (longest) contig from fasta file and store it in pharokka/input_contigs
awk '/^>/ {if (seq) exit; seq=1} {print}' $one_fasta>$ANNOT_DIR/pharokka/input_contigs/${sample}_contig.fasta

mkdir -p $ANNOT_DIR/pharokka/$sample

# Run pharokka
# -i $ANNOT_DIR/pharokka/input_contigs/<file>
# -o $ANNOT_DIR/pharokka/$sample
# -d <wherever database installed>
pharokka.py -i $ANNOT_DIR/pharokka/input_contigs/${sample}_contig.fasta \
-o $ANNOT_DIR/pharokka/$sample \
-d /work/geisingerlab/Mark/genome_assembly/pharokka_databases \
-t 8 -p $sample

# Make plot
pharokka_plotter.py -i $ANNOT_DIR/pharokka/input_contigs/${sample}_contig.fasta -n $sample_pharokka_plot -o $ANNOT_DIR/pharokka/$sample -p $sample -t 'Phage $sample'