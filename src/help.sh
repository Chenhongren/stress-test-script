#!/bin/bash

source "`dirname -- "$0";`"/parameters.sh

func_help() {
        printf "Linux stress EC tool, version %s" "$version"
        printf "\n\nUsage:\n sudo bash $0 -t {test case} [options]\n"
        printf "\nSupported test case in default json file($input_json):\n"

        length=$(jq -r '.case|length' $input_json)
        for (( i=0; i<$((length)); i=i+1 )); do
                str=".case[$i].name"
                case=$(jq -r $str $input_json)
                printf "  "$case"\n"
        done

        printf "\nOptions:\n"
        printf "\t--json    | -j Load JSON file, defalut: input/default.json\n"
        printf "\t--help    | -h Help\n"
        exit 1
}
