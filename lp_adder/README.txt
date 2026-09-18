FLAT LOW-POWER REGISTERED ADDER EXERCISE
===========================================

Files:
  registered_adder.sv       RTL
  tb_registered_adder.sv    constrained-random TB + scoreboard
                            + assertions + functional coverage
  adder.sdc                 timing constraints
  adder.upf                 basic UPF power intent
  dc.tcl                    Design Compiler synthesis
  pt.tcl                    PrimeTime STA
  run_vcs.sh                VCS simulation + code coverage

VCS:
  vcs -full64 -sverilog registered_adder.sv tb_registered_adder.sv \
      -debug_access+all -kdb -cm line+cond+branch+tgl -o simv

  ./simv

Verdi:
  verdi -ssf adder.fsdb

Code coverage:
  The testbench/script enables:
    line
    condition
    branch
    toggle

Functional coverage:
  covergroup adder_cg contains:
    valid coverage
    operand bins
    sum/carry bins
    A x B cross coverage

Assertions:
  valid latency
  addition correctness
  no-spurious-valid

Design Compiler:
  Edit the SKY130 .db path in dc.tcl, then:
    dc_shell -f dc.tcl

PrimeTime:
  Edit the SKY130 .db path in pt.tcl, then:
    pt_shell -f pt.tcl

UPF:
  The UPF intentionally does not invent a SKY130 power-switch
  cell. Once the exact SKY130 LP library is known, add the
  appropriate power-switch mapping.
