#!/bin/bash
# Read the cp2k.out file and check if the calculation converged.
# Works for Dimer optimization and TS optimization
echo  `grep "GEOMETRY OPTIMIZATION COMPLETED" $1 |wc -l `
