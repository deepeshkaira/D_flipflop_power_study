file mkdir lib/asap7_db

set library_specs {
    {lib/asap7_nldm/asap7sc7p5t_AO_RVT_TT_08302018.lib asap7sc7p5t_AO_RVT_TT_08302018 lib/asap7_db/asap7sc7p5t_AO_RVT_TT_08302018.db}
    {lib/asap7_nldm/asap7sc7p5t_INVBUF_RVT_TT_08302018.lib asap7sc7p5t_INVBUF_RVT_TT_08302018 lib/asap7_db/asap7sc7p5t_INVBUF_RVT_TT_08302018.db}
    {lib/asap7_nldm/asap7sc7p5t_OA_RVT_TT_08302018.lib asap7sc7p5t_OA_RVT_TT_08302018 lib/asap7_db/asap7sc7p5t_OA_RVT_TT_08302018.db}
    {lib/asap7_nldm/asap7sc7p5t_SEQ_RVT_TT_08302018.lib asap7sc7p5t_SEQ_RVT_TT_08302018 lib/asap7_db/asap7sc7p5t_SEQ_RVT_TT_08302018.db}
    {lib/asap7_nldm/asap7sc7p5t_SIMPLE_RVT_TT_08302018.lib asap7sc7p5t_SIMPLE_RVT_TT_08302018 lib/asap7_db/asap7sc7p5t_SIMPLE_RVT_TT_08302018.db}
}

foreach spec $library_specs {
    lassign $spec source_file library_name output_file
    if {![file readable $source_file]} {
        error "Cannot read ASAP7 source Liberty: $source_file"
    }
    read_lib $source_file
    write_lib $library_name -format db -output $output_file
}

exit

