#!/bin/bash
## combine.sbatch: run combine.R once all simulation jobs have finished
#SBATCH --job-name=combine
#SBATCH --partition=epimodel
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=00:10:00
#SBATCH --output=logs/%x_%j.out

. /projects/epimodel/spack/share/spack/setup-env.sh
spack unload -a
spack load r@4.6.1

Rscript combine.R
