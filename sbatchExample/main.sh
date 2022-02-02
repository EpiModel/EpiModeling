#!/bin/bash

sbatch -p epimodel --array=1-2 --cpus-per-task=32 --time=1:00:00 --mem=0 --job-name=s1000 --export=ALL,SIMNO=1000,TP=0.1,TP2=0.2 runsim.sh
sbatch -p epimodel --array=1-2 --cpus-per-task=32 --time=1:00:00 --mem=0 --job-name=s1001 --export=ALL,SIMNO=1001,TP=0.2,TP2=0.2 runsim.sh
sbatch -p epimodel --array=1-2 --cpus-per-task=32 --time=1:00:00 --mem=0 --job-name=s1002 --export=ALL,SIMNO=1002,TP=0.1,TP2=0.4 runsim.sh
sbatch -p epimodel --array=1-2 --cpus-per-task=32 --time=1:00:00 --mem=0 --job-name=s1003 --export=ALL,SIMNO=1003,TP=0.2,TP2=0.4 runsim.sh
