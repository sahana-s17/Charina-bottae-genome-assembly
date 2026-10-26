#!/bin/bash
#SBATCH --job-name=charina_download_reads
#SBATCH --cpus-per-task=8
#SBATCH --mem=32g
#SBATCH --gres=lscratch:2000
#SBATCH --time=12==24:00:00
#SBATCH --output=charina_download_reads_%j.out
#SBATCH --error=charina_download_reads_%j.err
#SBATCH --mail-type=ALL

set -euo pipefail

module load sratoolkit/3.4.0
module load pigz

OUTDIR="/data/Wilson_Lab/projects/Group_Genome_Assembly/Charina_bottae/raw_reads"
TMPDIR="/lscratch/$SLURM_JOBID"

mkdir -p "$OUTDIR"

echo "Job started: $(date)"
echo "Running on: $(hostname)"
echo "Job ID: $SLURM_JOBID"
echo "Output directory: $OUTDIR"
echo "Scratch directory: $TMPDIR"
echo "SRA Toolkit:"
fasterq-dump --version

# Download SRA runs
## Default max size is 20g, need to increase since all 3 files are larger than 20g)
prefetch --max-size 100g -O "$TMPDIR" SRR19599929
prefetch --max-size 100g -O "$TMPDIR" SRR19599928
prefetch --max-size 100g -O "$TMPDIR" SRR19599927

# fastrq dump SRR19599929 (don't need to split into paired FASTQ since this isn't a paired accession)
fasterq-dump SRR19599929 \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"

# Convert SRR19599928 to paired FASTQ
fasterq-dump SRR19599928 \
    --split-files \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"

# Convert SRR19599927 to paired FASTQ
fasterq-dump SRR19599927 \
    --split-files \
    --threads "$SLURM_CPUS_PER_TASK" \
    --temp "$TMPDIR" \
    --outdir "$OUTDIR"


# Compress FASTQ files 
pigz -p "$SLURM_CPUS_PER_TASK" \
    "$OUTDIR"/SRR19599928_1.fastq \
    "$OUTDIR"/SRR19599928_2.fastq \
    "$OUTDIR"/SRR19599927_1.fastq \
    "$OUTDIR"/SRR19599927_2.fastq \
    "$OUTDIR"/SRR19599929.fastq 

# Rename to R1/R2 convention (only the Omni-C data since it is short read)
mv "$OUTDIR/SRR19599928_1.fastq.gz" "$OUTDIR/SRR19599928_R1.fastq.gz"
mv "$OUTDIR/SRR19599928_2.fastq.gz" "$OUTDIR/SRR19599928_R2.fastq.gz"

mv "$OUTDIR/SRR19599927_1.fastq.gz" "$OUTDIR/SRR19599927_R1.fastq.gz"
mv "$OUTDIR/SRR19599927_2.fastq.gz" "$OUTDIR/SRR19599927_R2.fastq.gz"

echo
echo "Final files:"
ls -lh "$OUTDIR"/SRR1959992*.fastq.gz

echo
echo "Job finished: $(date)" 