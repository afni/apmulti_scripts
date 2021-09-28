#!/bin/tcsh

# running SSW

sbatch                                                             \
    --partition=norm,quick                                         \
    --cpus-per-task=16                                             \
    --mem=4g                                                       \
    --time=03:59:00                                                \
    --gres=lscratch:2                                              \
    do_03*.tcsh
