## combine.R: stack all saved batches into one data frame and summarize them

files <- list.files("output", pattern = "^sim_.*\\.rds$", full.names = TRUE)
if (length(files) == 0) stop("No sim_*.rds files found in output/")

all_sims <- do.call(rbind, lapply(files, readRDS))
saveRDS(all_sims, "all_sims.rds")
cat("Combined", length(files), "files and", nrow(all_sims), "rows into all_sims.rds\n")

## Mean prevalence at the last time step, by scenario
last <- all_sims[all_sims$time == max(all_sims$time), ]
last$prev <- last$i.num / last$num
print(aggregate(prev ~ inf_prob + act_rate, data = last, FUN = mean))
