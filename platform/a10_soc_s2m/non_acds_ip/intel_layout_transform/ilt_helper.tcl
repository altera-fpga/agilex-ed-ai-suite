proc ilt_add_clk { name } {
  add_interface ${name} clock end
  set_interface_property ${name} clockRate 0
  set_interface_property ${name} ENABLED true
  add_interface_port ${name} ${name} clk Input 1
}

proc ilt_add_rst { name clk } {

  add_interface ${name} reset end
  set_interface_property ${name} associatedClock $clk
  set_interface_property ${name} synchronousEdges DEASSERT
  set_interface_property ${name} ENABLED true
  add_interface_port ${name} ${name} reset Input 1
}

proc ilt_add_avlst_interface { prefix clk rst {dir slave} width}  {

  if {$dir == "master"} {
    set master_out "Output"
    set master_in  "Input"
    set direction "start"
    set pref_in "i_"
    set pref_out "o_"
  } else {
    set master_out "Input"
    set master_in  "Output"
    set direction "end"
    set pref_in "o_"
    set pref_out "i_"
  }

  add_interface $prefix avalon_streaming $direction
  set_interface_property $prefix dataBitsPerSymbol 8
  set_interface_property $prefix readyLatency 0
  set_interface_property $prefix symbolsPerBeat 1
  set_interface_property $prefix associatedClock $clk

  add_interface_port $prefix $pref_out${prefix}_tdata  data $master_out $width
  add_interface_port $prefix $pref_out${prefix}_tvalid valid $master_out  1
  add_interface_port $prefix $pref_in${prefix}_tready ready $master_in 1
}

proc ilt_add_axi4st_interface { prefix clk rst {dir slave} width}  {

  if {$dir == "master"} {
    set master_out "Output"
    set master_in  "Input"
    set direction "start"
    set pref_in "i_"
    set pref_out "o_"
  } else {
    set master_out "Input"
    set master_in  "Output"
    set direction "end"
    set pref_in "o_"
    set pref_out "i_"
  }

  add_interface $prefix axi4stream $direction
  set_interface_property $prefix associatedClock $clk
  set_interface_property $prefix associatedReset $rst

  add_interface_port $prefix $pref_out${prefix}_tdata  tdata  $master_out $width
  add_interface_port $prefix $pref_out${prefix}_tvalid tvalid $master_out 1
  add_interface_port $prefix $pref_in${prefix}_tready tready $master_in 1
  add_interface_port $prefix $pref_out${prefix}_tuser tuser $master_out 1
  add_interface_port $prefix $pref_out${prefix}_tlast tlast $master_out 1

#  set_port_property ${prefix}_tuser VHDL_TYPE STD_LOGIC_VECTOR

}

proc ilt_add_axi4lite_interface { prefix clk rst {AWIDTH 16} {dir slave} width}  {

  if {$dir == "master"} {
    set master_out "Output"
    set master_in  "Input"
    set direction "start"
    set pref_in "i_"
    set pref_out "o_"

  } else {
    set master_out "Input"
    set master_in  "Output"
    set direction "end"
    set pref_in "o_"
    set pref_out "i_"
  }

  ######################################################################################
  add_interface $prefix axi4lite $direction
  set_interface_property $prefix associatedClock $clk
  set_interface_property $prefix associatedReset $rst
  set_interface_property $prefix ENABLED true
  set_interface_property $prefix EXPORT_OF ""
  set_interface_property $prefix PORT_NAME_MAP ""
  set_interface_property $prefix CMSIS_SVD_VARIABLES ""
  set_interface_property $prefix SVD_ADDRESS_GROUP ""

  add_interface_port $prefix $pref_out${prefix}_awaddr awaddr $master_out $AWIDTH
  add_interface_port $prefix $pref_out${prefix}_awvalid awvalid $master_out 1
  add_interface_port $prefix $pref_in${prefix}_awready awready $master_in 1
  add_interface_port $prefix $pref_out${prefix}_wdata wdata $master_out $width
  add_interface_port $prefix $pref_in${prefix}_wready wready $master_in 1
  add_interface_port $prefix $pref_out${prefix}_wvalid wvalid $master_out 1
  add_interface_port $prefix $pref_out${prefix}_wstrb wstrb $master_out ($width/8)
  add_interface_port $prefix $pref_in${prefix}_bresp bresp $master_in 2
  add_interface_port $prefix $pref_in${prefix}_bvalid bvalid $master_in 1
  add_interface_port $prefix $pref_out${prefix}_bready bready $master_out 1
  add_interface_port $prefix $pref_in${prefix}_rdata rdata $master_in $width
  add_interface_port $prefix $pref_in${prefix}_rresp rresp $master_in 2
  add_interface_port $prefix $pref_in${prefix}_rvalid rvalid $master_in 1
  add_interface_port $prefix $pref_out${prefix}_rready rready $master_out 1
  add_interface_port $prefix $pref_out${prefix}_araddr araddr $master_out $AWIDTH
  add_interface_port $prefix $pref_out${prefix}_arvalid arvalid $master_out 1
  add_interface_port $prefix $pref_in${prefix}_arready arready $master_in 1
  add_interface_port $prefix $pref_out${prefix}_awprot awprot $master_out 3
  add_interface_port $prefix $pref_out${prefix}_arprot arprot $master_out 3

}
