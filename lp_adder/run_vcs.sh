#!/bin/bash

vcs -full64 \
    -sverilog \
    registered_adder.sv \
    tb_registered_adder.sv \
    -debug_access+all \
    -kdb \
    -cm line+cond+branch+tgl \
    -cm_dir coverage.vdb \
    -o simv

./simv \
    -cm line+cond+branch+tgl
