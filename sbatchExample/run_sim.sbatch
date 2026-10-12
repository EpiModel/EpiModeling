#!/bin/bash
## run_sim.sbatch: run sim.R as a job array of 4 tasks
#SBATCH --job-name=sim
#SBATCH --partition=epimodel
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --array=1-4
#SBATCH --output=logs/%x_%A_%a.out

## Load R from the lab's Spack installation
. /projects/epimodel/spack/share/spack/setup-env.sh
spack unload -a
spack load r@4.6.1

Rscript sim.R
