## sim.R: simulate one batch of a simple SIS network model and save the results

suppressPackageStartupMessages(library(EpiModel))

## Settings come from environment variables. Slurm sets the SLURM_ ones, and
## submit_all.sh passes INF_PROB and ACT_RATE with `sbatch --export`. The
## defaults are used when a variable is not set, for example on your computer.
task_id  <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID", unset = "1"))
ncores   <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = "1"))
inf_prob <- as.numeric(Sys.getenv("INF_PROB", unset = "0.2"))
act_rate <- as.numeric(Sys.getenv("ACT_RATE", unset = "1"))

set.seed(task_id)
cat(R.version.string, "on", Sys.info()[["nodename"]], "\n")
cat("Task", task_id, "| inf_prob =", inf_prob, "| act_rate =", act_rate, "\n")

## Network model: 500 nodes, 150 partnerships, mean duration 20 time steps
nw <- network_initialize(n = 500)
est <- netest(
  nw,
  formation = ~edges,
  target.stats = 150,
  coef.diss = dissolution_coefs(dissolution = ~offset(edges), duration = 20),
  verbose = FALSE
)

## Epidemic model: one simulation per core
param <- param.net(inf.prob = inf_prob, act.rate = act_rate, rec.rate = 0.02)
init <- init.net(i.num = 10)
control <- control.net(
  type = "SIS", nsteps = 100,
  nsims = ncores, ncores = ncores, verbose = FALSE
)
sim <- netsim(est, param, init, control)

## Save a small data frame, not the whole netsim object
out <- as.data.frame(sim)
out$inf_prob <- inf_prob
out$act_rate <- act_rate
out$task_id <- task_id
dir.create("output", showWarnings = FALSE)
fn <- paste0("sim_ip", inf_prob, "_ar", act_rate, "_", task_id, ".rds")
saveRDS(out, file.path("output", fn))

last <- out[out$time == max(out$time), ]
cat("Saved output/", fn, " | simulations = ", ncores,
    " | mean prevalence at the last step = ",
    round(mean(last$i.num / last$num), 3), "\n", sep = "")
