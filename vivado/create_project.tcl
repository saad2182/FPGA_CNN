# Recreate the original Nexys4 DDR hardware project without committing Vivado output.
set repo_root [file normalize [file join [file dirname [info script]] ".."]]
set build_dir [file join $repo_root "build" "vivado"]

create_project -force fpga_cnn_pattern_detector $build_dir -part xc7a100tcsg324-3

add_files -norecurse [list \
    [file join $repo_root "rtl" "core" "convpattern.v"] \
    [file join $repo_root "rtl" "core" "convsample.v"] \
    [file join $repo_root "rtl" "core" "dotproduct.v"] \
    [file join $repo_root "rtl" "core" "clockDiv.v"] \
    [file join $repo_root "rtl" "core" "vgapulse.v"] \
    [file join $repo_root "rtl" "top" "top_vga.v"]]

add_files -norecurse [list \
    [file join $repo_root "data" "memory" "pattern_hex.txt"] \
    [file join $repo_root "data" "memory" "sample_hex.txt"]]

add_files -fileset constrs_1 -norecurse \
    [file join $repo_root "constraints" "nexys4-ddr.xdc"]

set_property top top [get_filesets sources_1]
update_compile_order -fileset sources_1

puts "Created Vivado project at $build_dir"
