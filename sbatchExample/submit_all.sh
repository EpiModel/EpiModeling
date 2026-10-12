#!/bin/bash
## submit_all.sh: submit one job array per parameter combination, then a job
## that combines the results once every array has finished.
## Run it on the HPC login node with: bash submit_all.sh

## Stop at the first error, and work from the folder that holds this script
set -e
cd "$(dirname "$0")"

## Slurm does not create folders. If the --output folder is missing, the job
## fails at once and leaves no log.
mkdir -p logs output

## Parameter values to cross: 2 x 2 = 4 scenarios
INF_PROBS="0.2 0.4"
ACT_RATES="1 2"

JOB_IDS=""
for ip in $INF_PROBS; do
  for ar in $ACT_RATES; do
    ## --export passes the values to sim.R as environment variables, and
    ## --parsable makes sbatch print only the job ID so we can save it
    id=$(sbatch --parsable \
      --job-name=sim_ip${ip}_ar${ar} \
      --export=ALL,INF_PROB=${ip},ACT_RATE=${ar} \
      run_sim.sbatch)
    echo "Submitted job ${id}: INF_PROB=${ip} ACT_RATE=${ar}"
    JOB_IDS="${JOB_IDS}:${id}"
  done
done

## afterok: start only after every task of every array finished successfully
id=$(sbatch --parsable --dependency=afterok${JOB_IDS} combine.sbatch)
echo "Submitted job ${id}: combine, after jobs ${JOB_IDS#:}"
