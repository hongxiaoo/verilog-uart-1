# ========================================
# Program Device
# ========================================

set PRJ_NAME $::env(PRJ_NAME)
set TOP      $::env(TOP)
set RTL_SRC  $::env(RTL_SRC)
set XDC      $::env(XDC)
set DEVICE   $::env(DEVICE)
set PROGRAM  $::env(PROGRAM)

set OUTPUT $PRJ_NAME/output

open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE "$OUTPUT/$TOP.bit" [current_hw_device]
program_hw_device [current_hw_device]

exit