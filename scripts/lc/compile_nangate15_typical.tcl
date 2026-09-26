file mkdir lib/nangate15_db

set source_lib /apps/cds/ic618/local/NanGate_15nm/front_end/timing_power_noise/NLDM/NanGate_15nm_OCL_typical_conditional_nldm.lib

if {![file readable $source_lib]} {
    error "Cannot read NanGate source Liberty: $source_lib"
}

read_lib $source_lib
write_lib NanGate_15nm_OCL -format db -output lib/nangate15_db/NanGate_15nm_OCL_typical.db

exit

