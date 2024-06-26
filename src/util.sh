#!/bin/bash

func_printf() {
	local save=$1
	local output_file=""
	local str=""
	if [ "$save" -eq 1 ]; then
		output_file=$2
		str=$3
	else
		str=$2
	fi

	printf "$str"
	if [ "$save" -eq 1 ]; then
		printf "$str" >> "$output_file";
	fi
}
