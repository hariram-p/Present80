# Low-Power Registered Adder — VCS / Verdi / DC / PrimeTime / UPF

Learning flow:

1. RTL simulation with VCS
2. Debug waveforms with Verdi
3. Add random verification, scoreboard, assertions and coverage
4. Synthesize with Design Compiler
5. Run STA with PrimeTime
6. Introduce UPF
7. Add actual low-power cell mapping after checking the installed SKY130 libraries

## First run

VCS:
    vcs -full64 -sverilog rtl/registered_adder.sv tb/tb_registered_adder.sv -debug_access+all -kdb -o simv
    ./simv

Verdi:
    verdi -ssf adder.fsdb

Design Compiler:
    cd dc
    dc_shell -f dc.tcl

PrimeTime:
    cd pt
    pt_shell -f pt.tcl

## Important

The DC and PrimeTime scripts contain a placeholder:

    /path/to/sky130_library.db

Replace it with the real .db path on your machine.

The supplied UPF intentionally does not invent a SKY130 power-switch cell. Before implementing physical power gating, inspect the exact SKY130 libraries available on your system and map the UPF power switch to a real characterized cell.
