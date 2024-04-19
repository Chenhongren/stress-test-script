#!/bin/bash

source "`dirname -- "$0";`"/parameters.sh
source "`dirname -- "$0";`"/util.sh

func_preinit() {
	local first=$1

	printf "\n\nPre-Init >> "

	if [ "$first" -eq 1 ]; then
		if [ $input_save == "enable" ]; then
			stress_output_file="output/$input_test_case"_"$(date +"%Y-%m-%d")".log
			if ! test -f $stress_output_file; then
				touch $stress_output_file;
			else
				printf "\nStress output file($stress_output_file) is already exist. Please check!\n";
				exit 1;
			fi
		fi

		str=".case[$case_index].ec_console"
		if [ "$(jq -r $str $input_json)" != "nope" ]; then
			str=".case[$case_index].ec_console.source"
			case "$(jq -r $str $input_json)" in
			"device" )
				str=".case[$case_index].ec_console.location"
				location=$(jq -r $str $input_json)
				str=".case[$case_index].ec_console.baudrate"
				baudrate=$(jq -r $str $input_json)

				ec_console_filename="input/ec_console_$(date +"%Y-%m-%d").log"
				if ! test -f $ec_console_filename; then
					stty -F "$ec_console_filename" "$baudrate" -parity cs8 cstopb
					cat $location > "$ec_console_filename" &
					if [ $? -ne 0 ]; then
						printf "\nFailed to access $location. Please check!\n"
						exit 1;
					fi
					printf "\nCreated a job to dump $location:\n"
					jobs -l
					pid=$(jobs -l |grep "cat"| cut -f2 -d" ")
				else
					printf "\nEC console file($ec_console_filename) is already exist. Please check!\n";
					exit 1;
				fi
			;;
			"file" )
				str=".case[$case_index].ec_console.location"
				ec_console_filename=$(jq -r $str $input_json)
				if ! test -f $ec_console_filename; then
					printf "\nMissing EC console file($ec_console_filename). Please check!\n"
					exit 1
				fi
			;;
			esac
		fi
	fi

	printf "Done"
}

func_postinit() {
	local first=$1

	printf "Post-Init >> "

	case "$validation" in
		"string-comparison" )
			str=".validation[$validation_index].string|length"
			lenth=$(jq -r $str $input_json)
			for (( i=0; i<$((lenth)); i=i+1 )); do
				str=".validation[$validation_index].string[$i][0]"
				validation_string[$i]=$(jq -r $str $input_json)
				validation_string_init[$i]=$(cat $ec_console_filename |grep -c "${validation_string[$i]}")
				$cmd_printf "\n  String[$i]: ${validation_string[$i]}, Count: ${validation_string_init[$i]}"
			done
		;;
	esac

	printf "\nDone\n\n"
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
	if [ "$validation" != "nope" ]; then
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
	if [ $input_rerun == "enable" ]; then
		$cmd_printf "enable\n"
	else
		$cmd_printf "disable\n"
	fi
	$cmd_printf "  Save: "
	if [ $input_save == "enable" ]; then
		$cmd_printf "enable\n"
	else
		$cmd_printf "disable\n"
	fi

	curr_cnt=0

	$cmd_printf "\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"

	func_postinit $first

}
