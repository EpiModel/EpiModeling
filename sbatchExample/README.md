# sbatchExample

A small, complete example of passing parameters to an R script through `sbatch` on the RSPH HPC. A driver script submits one job array for each combination of two parameters, and a last job combines the results once every array has finished. It uses plain Slurm and EpiModel from CRAN. The wiki page [Running R with a batch job with sbatch](https://github.com/EpiModel/EpiModeling/wiki/Running-R-with-a-batch-job-with-sbatch) walks through it step by step.

## Files

- `sim.R`: simulates one batch of an SIS network model and saves a small data frame to `output/`. It reads `INF_PROB` and `ACT_RATE` from environment variables, with defaults, so it also runs on your own computer.
- `run_sim.sbatch`: job script that loads R 4.6.1 and runs `sim.R` as an array of 4 tasks (2 CPUs, 4 GB, and 30 minutes each). Each task uses its task number as the random seed and runs one simulation per CPU.
- `combine.R`: stacks every file in `output/` into `all_sims.rds` and prints the mean prevalence at the last time step for each scenario.
- `combine.sbatch`: job script that runs `combine.R`.
- `submit_all.sh`: creates `logs/` and `output/`, submits `run_sim.sbatch` once for each combination of `INF_PROB` (0.2, 0.4) and `ACT_RATE` (1, 2), passing the values with `--export`, and then submits `combine.sbatch` with `--dependency=afterok` on all four job IDs.

## Run it on your computer first

You need EpiModel from CRAN. From this folder:

```bash
Rscript sim.R
INF_PROB=0.4 ACT_RATE=2 Rscript sim.R
Rscript combine.R
```

Each run of `sim.R` takes a few seconds and adds one file to `output/`.

## Run it on the HPC

EpiModel must be installed in your R 4.6.1 library on the HPC. Install it once from an `srun` session that loads R with the same `spack load r@4.6.1` line as the job scripts.

Then, on the login node:

```bash
cd /projects/epimodel/<netid>
git clone https://github.com/EpiModel/EpiModeling.git
cd EpiModeling/sbatchExample
bash submit_all.sh
squeue -u $USER
```

`submit_all.sh` prints the job ID of each array and of the combine job. Each task writes its log to `logs/`, for example `logs/sim_ip0.2_ar1_<jobid>_1.out`. The combine job waits in the queue with reason `Dependency` until all four arrays finish. Its log, `logs/combine_<jobid>.out`, shows the summary table, and `all_sims.rds` holds every simulation. To copy it to your computer, run this locally:

```bash
scp <netid>@clogin01.sph.emory.edu:/projects/epimodel/<netid>/EpiModeling/sbatchExample/all_sims.rds .
```

To try other values, edit `INF_PROBS` and `ACT_RATES` at the top of `submit_all.sh`.

## What our projects use

Hand-written job scripts like these are for learning and for small one-off jobs. Our modeling projects run full simulation campaigns with the `slurmworkflow` package, which writes and chains the job scripts for you. See [Running Project Workflows on the HPC](https://github.com/EpiModel/EpiModeling/wiki/Running-Project-Workflows-on-the-HPC).
