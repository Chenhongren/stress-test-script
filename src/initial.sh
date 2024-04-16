#!/bin/bash

source "`dirname -- "$0";`"/parameters.sh
source "`dirname -- "$0";`"/util.sh

func_preinit() {
	local first=$1

	printf "\n\nPre-Init >> "

	if [ "$first" -eq 1 ]; then
		if [ $input_save -eq 1 ]; then
			stress_output_file="output/$input_test_case"_"$(date +"%Y-%m-%d")".log
			if ! test -f $stress_output_file; then
				touch $stress_output_file;
			else
				printf "\nStress output file($stress_output_file) is already exist. Please check!\n";
				exit 1;
			fi
		fi

		if [ "$input_test_case" == "${test_case_supported[0]}" ]; then
			if [ "$binary_file_path" == "" ]; then
				printf "\nMissing EC binary file. Please check!\n"
				exit 1;
			elif ! test -f $binary_file_path; then
				printf "\nMissing EC binary file($binary_file_path). Please check!\n"
				exit 1;
			fi

			ec_console_filename="input/ec_console_$(date +"%Y-%m-%d").log"
			if ! test -f $ec_console_filename; then
				cat /dev/ttyUSB0 > "$ec_console_filename" &
				if [ $? -ne 0 ]; then
					printf "\nFailed to access /dev/ttyUSB0. Please check!\n"
					exit 1;
				fi
				printf "\nCreated a job to dump /dev/ttyUSB0:\n"
				jobs -l
				pid=$(jobs -l |grep "cat /dev/ttyUSB0"| cut -f2 -d" ")
			else
				printf "\nEC console file($ec_console_filename) is already exist. Please check!\n";
				exit 1;
			fi
			printf "..."
		fi

		if [ "$input_test_case" == "${test_case_supported[1]}" ]; then
			printf "..."
		fi
	fi

	printf "Done"
}

func_postinit() {
	local first=$1

	printf "Post-Init >> "

	if [ "$first" -eq 1 ]; then
		if [ "$input_test_case" == "${test_case_supported[0]}" ]; then
			printf "..."
		fi

		if [ "$input_test_case" == "${test_case_supported[1]}" ]; then
			printf "..."
		fi
	fi

	if [ "$input_test_case" == "${test_case_supported[0]}" ]; then
		successful_cnt_init=$(cat $ec_console_filename |grep -c "PROJECT EXECUTION SUCCESSFUL")
		failed_cnt_init=$(cat $ec_console_filename |grep -c "PROJECT EXECUTION FAILED")
		$cmd_printf "\n\nSuccessful count: $successful_cnt_init, Failed count: $failed_cnt_init\n"
	fi

	printf "Done\n\n"
}

func_initialization() {
	local first=$1

	func_preinit $first

	cmd_printf="func_printf $input_save $stress_output_file"

	$cmd_printf "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
	if [ "$first" -eq 1 ]; then
		$cmd_printf "INIT >>\n"
	else
		$cmd_printf "RERUN($rerun_times) INIT >>\n"
	fi

	$cmd_printf "  Test case: $input_test_case\n"
	$cmd_printf "  Validation: "
	if [ $input_verify -eq 1 ]; then
	$cmd_printf "enable\n"
	else
	$cmd_printf "disable\n"
	fi
	$cmd_printf "  Count: "
	if [ $input_count -eq 0 ]; then
		$cmd_printf "infinite\n"
	else
		$cmd_printf "$input_count\n"
	fi
	$cmd_printf "  Rerun: "
	if [ $input_rerun -eq 1 ]; then
		$cmd_printf "enable\n"
	else
		$cmd_printf "disable\n"
	fi
	$cmd_printf "  Save: "
	if [ $input_save -eq 1 ]; then
		$cmd_printf "enable\n"
	else
		$cmd_printf "disable\n"
	fi

	curr_cnt=0

	$cmd_printf "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"

	func_postinit $first

}
