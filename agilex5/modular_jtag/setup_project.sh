#!/bin/sh
# To be called by $COREDLA_ROOT/scripts/dla_build_example_design.py
# Purpose: set up the files necessary for Quartus project, without invoking any Quartus tools

# System variables
alias cp="cp --verbose"
qsys_top="ed_zero"
# Create the Qsys system one directory down in "qsys" to keep top directory clean
mkdir qsys
cp ed_zero.tcl qsys/

# Copy the hw timer file
cp ${COREDLA_ROOT}/platform/rtl/* .