#!/bin/bash

. /projects/epimodel/spack/share/spack/setup-env.sh
spack load r@4.1.2

Rscript sim.R
