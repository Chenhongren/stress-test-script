# Linux stress EC tool, version v1.0

## Dependency:

"jq" is a lightweight and flexible command-line JSON processor. For more details, please refer to the [website](https://jqlang.github.io/jq/).
```
    # sudo apt install jq
```

## Concept
There are five steps.

- Parsing: Parse the config file, which includes testing information

- Initialization: Initial parameters, the output file, etc

- Running: Execute the command

- Validation: Verify the test result

- Summary: Print the summary result

## Usage:

Command:
````
    sudo bash src/main.sh -t {test case} [options]
````

Supported test case:

- ec_fw_update
- test

Options:
```
    --json    | -j Load JSON file, defalut: input/default.json
    --help    | -h Help
```
