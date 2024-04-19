#!/bin/bash

source "`dirname -- "$0";`"/parameters.sh
source "`dirname -- "$0";`"/util.sh

func_validation() {
	local ret="unknown"
	$cmd_printf "VALIDATION>>\n"

	case "$validation" in
		"nope" )
			printf "No validation check for \"$input_test_case\" test case\n"
			ret="pass"
		;;
		"string-comparison" )
			str=".validation[$validation_index].string|length"
			lenth=$(jq -r $str $input_json)
			for (( i=0; i<$((lenth)); i=i+1 )); do
				str=".validation[$validation_index].string[$i][0]"
				validation_string[$i]=$(jq -r $str $input_json)
				str=".validation[$validation_index].string[$i][1]"
				validation_string_plus[$i]=$(jq -r $str $input_json)

				validation_string_cnt[$i]=$(cat $ec_console_filename |grep -c "${validation_string[$i]}")
				if [ "${validation_string_cnt[$i]}" != "$((curr_cnt*validation_string_plus[$i]+validation_string_init[$i]))" ]; then
					$cmd_printf "  String[$i]: ${validation_string[$i]}"
					$cmd_printf ",Value: ${validation_string_cnt[$i]}"
					$cmd_printf ",Expect: $((curr_cnt*validation_string_plus[$i]+validation_string_init[$i]))\n"
					$cmd_printf "  FAILED\n"
					ret="fail"
					break;
				else
					$cmd_printf "  String[$i]: ${validation_string[$i]}, PASS\n"
					ret="pass"
				fi
			done
		;;
	esac
	eval $1='$ret'
}
