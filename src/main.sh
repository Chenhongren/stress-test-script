##############################################
## Stress Test Script
## Date: 2024/4/11
## versioin: v1.0
## Author: Ren Chen <chen.ren.tw@gmail.com>
#############################################

#!/bin/bash

source "`dirname -- "$0";`"/help.sh
source "`dirname -- "$0";`"/parameters.sh
source "`dirname -- "$0";`"/util.sh
source "`dirname -- "$0";`"/summary.sh
source "`dirname -- "$0";`"/initial.sh
source "`dirname -- "$0";`"/validation.sh

while [ true ]; do
	if [ "$1" = "--test" -o "$1" = "-t" ]; then
		input_test_case=$2
		shift 2
	elif [ "$1" = "--json" -o "$1" = "-j" ]; then
		input_json=$2
		shift 2
		if ! test -f $input_json; then
			printf "Failed to access json file($input_json). Please check!\n"
			exit 1
		fi
	elif [ "$1" = "--help" -o "$1" = "-h" ]; then
		func_help
		shift 1
	else
			break
	fi
done

if ! jq . $input_json > /dev/null; then
	printf "Json format Error, file: $input_json. Please check!\n"
	exit 1;
fi

length=$(jq -r '.case|length' $input_json)
for (( i=0; i<=$((length)); i=i+1 )); do
	if [ "$i" == "$length" ]; then
		printf "Unknown test case($input_test_case). Please check!\n"
		func_help
		exit 1;
	fi
	str=".case[$i].name"
	name=$(jq -r $str $input_json)
	if [ "$name" == "$input_test_case" ]; then
		case_index=$i;
		case_name=$name;
		break;
	fi
done

str=".case[$case_index].command"
command=$(jq -r $str $input_json)
if [ "$command" == "null" ]; then
	printf "Unknown command for test case($input_test_case). Please check!\n"
	exit 1
fi

str=".case[$case_index].ec_console"
if [ "$(jq -r $str $input_json)" == "null" ]; then
	printf "Unknown ec_console for test case($input_test_case). Please check!\n"
	exit 1
fi

str=".case[$case_index].waiting_sec"
waiting_sec=$(jq -r $str $input_json)
if [ "$waiting_sec" == "null" ]; then
	printf "WARRING:\nUnknown waiting_sec label for test case($input_test_case). Default: 3 second\n"
	waiting_sec=3
fi

str=".case[$case_index].validation"
validation=$(jq -r $str $input_json)
if [ "$validation" == "null" ]; then
	printf "Unknown validation for test case($input_test_case). Please check!\n"
	exit 1
fi

if [ "$validation" != "nope" ]; then
	while [ true ]; do
		str=".validation[$validation_index].name"
		validation_name=$(jq -r $str $input_json)
		if [ "$validation_name" == "null" ]; then
			printf "Unknown validation($validation). Please check Json file!\n"
			exit 1
		elif [ "$validation_name" == "$validation" ]; then
			break
		fi
		validation_index=$((validation_index+1))
	done
fi

input_rerun=$(jq -r '.rerun' $input_json)
input_save=$(jq -r '.save' $input_json)
input_count=$(jq -r '.count' $input_json)
if [ "$input_rerun" == "enable" ]; then
	if [ "$validation" == "nope" ]; then
		input_rerun="disable"
		printf "WARRING:\nSince validation check is disabled, the rerun flag is disabled automatically.\n"
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

	if [ "$command" != "nope" ]; then
		$command
		if [ $? -ne 0 ]; then
			$cmd_printf "\nFailed to execute \"$command\". Please check!\n"
			func_summary $((0))
			exit 1;
		fi
	fi

	secs=$waiting_sec
	while [ $secs -gt 0 ]; do
		$cmd_printf "Waiting...$secs\033[0K\r"
		sleep 1
		: $((secs--))
	done

	func_validation result

	input_exit=""
	read -p 'Exit? ' -t 5 input_exit
	if [ "$input_exit" == "y" ] || [ "$input_exit" == "yes" ]; then
		if [ "$result" == "fail" ]; then
			func_summary $((0))
		elif [ "$result" == "pass" ]; then
			func_summary $((1))
		fi
	fi

	if [ "$result" == "fail" ]; then
		if [ "$input_rerun" == "disable" ] || [ "$rerun_times" -eq 5 ]; then
			func_summary $((0))
			exit 1;
		fi
		rerun_times=$((rerun_times+1))
		func_initialization $((0))
	elif [ "$result" == "pass" ]; then
		if [ "$input_count" -ne 0 ] && [ "$curr_cnt" -eq "$input_count" ]; then
			func_summary $((1))
		fi
	fi

done
