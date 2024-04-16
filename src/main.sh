##############################################
## Stress Test Script
## Date: 2024/4/11
## versioin: v0.1
## Author: Ren Chen <chen.ren.tw@gmail.com>
#############################################

#!/bin/bash

source "`dirname -- "$0";`"/help.sh
source "`dirname -- "$0";`"/parameters.sh
source "`dirname -- "$0";`"/util.sh
source "`dirname -- "$0";`"/summary.sh
source "`dirname -- "$0";`"/initial.sh

while [ True ]; do
	if [ "$1" = "--file" -o "$1" = "-f" ]; then
		binary_file_path=$2
		shift 2
	elif [ "$1" = "--test" -o "$1" = "-t" ]; then
		input_test_case=$2
		shift 2
	elif [ "$1" = "--save" -o "$1" = "-s" ]; then
		input_save=1
		shift 1
	elif [ "$1" = "--verify" -o "$1" = "-v" ]; then
		input_verify=1
		shift 1
	elif [ "$1" = "--rerun" -o "$1" = "-r" ]; then
		input_rerun=1
		shift 1
	elif [ "$1" = "--count" -o "$1" = "-c" ]; then
		input_count=$2
		shift 2
	elif [ "$1" = "--help" -o "$1" = "-h" ]; then
		func_help
		shift 1
	else
    		break
	fi
done

test_case_match=0
len=${#test_case_supported[@]}
for (( i=0; i<$len; i=i+1 )); do
	if [ "$input_test_case" == "${test_case_supported[$i]}" ]; then
		test_case_match=1;
	fi
done
if [ $test_case_match -eq 0 ]; then
	printf "Test case($test_case_match) is not supported. Please check!\n"
	func_help
	exit 1;
fi

if [ $input_rerun -eq 1 ]; then
	if [ $input_verify -eq 0 ]; then 
		input_rerun=0
		printf "WARRING:\nSince validation check is disabled, the rerun flag is disabled automatically."
	fi
fi 

func_initialization $((1))

start=`date +%s`
while true; do
	curr_cnt=$((curr_cnt+1))
	rerun_result[$rerun_times]=$curr_cnt

	$cmd_printf "\n\t***************************\n"
	$cmd_printf "\tR("$rerun_times") "$curr_cnt"th times $(date +"%Y-%m-%d") $(date +"%H:%M:%S") "
	$cmd_printf "\n\t***************************\n"

	if [ "$input_test_case" == "${test_case_supported[0]}" ]; then
		sudo ite -f "$binary_file_path";
		if [ $? -ne 0 ]; then
			$cmd_printf "\nFailed to update EC FW. Please check!\n"
			func_summary $((0))
			exit 1;
		fi
		secs=30
	elif [ "$input_test_case" == "${test_case_supported[1]}" ]; then
		# Do nothing
		secs=3
	else
		secs=3
	fi

	while [ $secs -gt 0 ]; do
		$cmd_printf "Waiting...$secs\033[0K\r"
   		sleep 1
   		: $((secs--))
	done

	if [ "$input_verify" -eq 1 ]; then
		if [ "$input_test_case" == "${test_case_supported[0]}" ]; then
			successful_cnt=$(cat $ec_console_filename |grep -c "PROJECT EXECUTION SUCCESSFUL")
			failed_cnt=$(cat $ec_console_filename |grep -c "PROJECT EXECUTION FAILED")
			if [ "$successful_cnt" -ne "$((curr_cnt+successful_cnt_init))" ] || [ "$failed_cnt" -ne "$failed_cnt_init" ]; then
				$cmd_printf "\nDetect the \"PROJECT EXECUTION SUCCESSFUL\" number $successful_cnt"
				$cmd_printf ", should be $((curr_cnt+successful_cnt_init))";
				$cmd_printf "\nDetect the \"PROJECT EXECUTION FAILED\" number $failed_cnt"
				$cmd_printf ", should be $failed_cnt_init\n";
				if [ "$input_rerun" -eq 1 ]; then
					if [ "$rerun_times" -eq 5 ]; then
						$cmd_printf "VALIDATION>> FAIL\n"
						func_summary $((0))
						exit 1;
					fi
					$cmd_printf "VALIDATION>> FAIL\n"
					rerun_times=$((rerun_times+1))
					func_initialization $((0))
				else
					$cmd_printf "VALIDATION>> FAIL\n"
					func_summary $((0))
					exit 1;
				fi
			else
				$cmd_printf "\nVALIDATION>> PASS\n"
				input_exit=""
			fi
		elif [ "$input_test_case" == "${test_case_supported[1]}" ]; then
			$cmd_printf "No validation check for \"test\" test case\n"
			$cmd_printf "\nVALIDATION>> PASS\n"
			input_exit=""

		fi
	fi
	
	if [ "$input_count" -ne 0 ] && [ "$curr_cnt" -eq "$input_count" ]; then
		func_summary $((1))
	fi

	read -p 'Exit? ' -t 5 input_exit
	if [ "$input_exit" == "y" ] || [ "$input_exit" == "yes" ]; then
		func_summary $((1))
	fi
done
