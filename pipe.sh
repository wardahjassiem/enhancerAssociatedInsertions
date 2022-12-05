#!/bin/bash 
#SBATCH --job-name="nextflow"
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --partition=main           
#SBATCH --nodes=1
#SBATCH --threads-per-core=1
#SBATCH --mem=90GB

export PATH=~/tools/sratoolkit.2.10.8-ubuntu64/bin:$PATH

export PATH=~/tools/miniconda3/bin:$PATH

NEXTFLOW=~/tools/nextflow


cd ~/enhancerAssociatedInsertions

$NEXTFLOW run -profile slurm, final.nf -resume


