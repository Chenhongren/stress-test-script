version="v0.1"

test_case_supported=("ec_fw_update" "test")

input_test_case=""
input_rerun=0
input_verify=0
input_save=0
input_count=0 #count=0 means infinite loop

curr_cnt=0
rerun_times=0
rerun_result=(0,0,0,0,0,0)
binary_file_path=""
ec_console_filename=""
stress_output_file=""
pid=""
