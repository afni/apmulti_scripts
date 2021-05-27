#!/bin/tcsh

# running FS

sbatch                                                             \
    --partition=norm                                               \
    --cpus-per-task=4                                              \
    --mem=10g                                                      \
    --time=12:00:00                                                \
    --gres=lscratch:10                                             \
    do_02*.tcsh
