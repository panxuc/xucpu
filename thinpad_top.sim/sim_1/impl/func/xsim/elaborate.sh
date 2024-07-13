#!/bin/bash -f
# ****************************************************************************
# Vivado (TM) v2019.2 (64-bit)
#
# Filename    : elaborate.sh
# Simulator   : Xilinx Vivado Simulator
# Description : Script for elaborating the compiled design
#
# Generated by Vivado on Fri Jul 12 21:31:47 CST 2024
# SW Build 2708876 on Wed Nov  6 21:39:14 MST 2019
#
# Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
#
# usage: elaborate.sh
#
# ****************************************************************************
set -Eeuo pipefail
echo "xelab -wto 1e0777dd008c45fcbaffd6b18f2c35e9 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L secureip --snapshot tb_func_impl xil_defaultlib.tb xil_defaultlib.glbl -log elaborate.log"
xelab -wto 1e0777dd008c45fcbaffd6b18f2c35e9 --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L secureip --snapshot tb_func_impl xil_defaultlib.tb xil_defaultlib.glbl -log elaborate.log
