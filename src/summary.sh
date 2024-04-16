#!/bin/bash

source "`dirname -- "$0";`"/util.sh

func_summary() {
	local is_pass=$1

	$cmd_printf "\n\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
	$cmd_printf "Summary >>\n"
	$cmd_printf "  Test Case: $input_test_case\n"
	if [ "$binary_file_path" != "" ]; then
		$cmd_printf "  EC binary file: $binary_file_path\n"
	fi
	if [ "$ec_console_filename" != "" ]; then
		$cmd_printf "  EC console file: $ec_console_filename\n"
	fi
	if [ $input_verify -eq 1 ]; then
		if [ $is_pass -eq 1 ]; then
			$cmd_printf "  Validation:  PASS\n"
		elif [ $is_pass -eq 0 ]; then
			$cmd_printf "  Validation: FAIL\n"
		fi
	else
		$cmd_printf "  Validation: disable\n"
	fi

	$cmd_printf "  Rerun times: $rerun_times\n"
	$cmd_printf "\t|  Round |  Exp. |  Act. |\n"
	for (( i=0; i<=$rerun_times; i=i+1 )); do
		$cmd_printf "\t| ($i)th: |  $input_count |  ${rerun_result[$i]} |\n"
	done

	end=`date +%s`
	runtime=$((end-start));
	hours=$((runtime / 3600));
	minutes=$(( (runtime % 3600) / 60 ));
	seconds=$(( (runtime % 3600) % 60 ));
	$cmd_printf "  Execution time: $hours:$minutes:$seconds\n"
	$cmd_printf ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"

	if [ "$pid" != "" ]; then
		job=$(jobs -l)
		$cmd_printf "Jobs list:\n $job\n"
		$cmd_printf "Kill pid: $pid\n"
		sudo kill -9 $pid
	fi

	exit 0;
}
