#!/bin/bash

source "`dirname -- "$0";`"/parameters.sh

func_help() {
        printf "Linux stress EC tool, version %s" "$version"
        printf "\n\nUsage:\n\tsudo bash $0 -t {test case} -f {ec image binary} [options]\n"
        printf "Supported test_case:\n"
        len=${#test_case_supported[@]}
        for (( i=0; i<$((len)); i=i+1 )); do
                printf "\t${test_case_supported[$i]}\n"
        done
        printf "Options:\n"
        printf "\t--count   | -c Set test counts, defalut: 0(infinite loop)\n"
        printf "\t--verify  | -v Enable validatioin function, defalut: disable\n"
        printf "\t--rerun   | -r Rerun after failure, the max. rerun is 5 times, default: disable\n"
        printf "\t--save    | -s Save to file log, filename: {test case}_{year_month_day}.log, default: disable\n"
        printf "\t--help    | -h Help\n"
        exit 1
}
