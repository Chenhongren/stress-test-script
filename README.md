Linux stress EC tool, version v0.1

Usage:
    `sudo bash src/main.sh -t {test case} -f {ec image binary} [options]`

Supported test case:

- ec_fw_update
- test

Options:
```
    --count   | -c Set test counts, defalut: 0(infinite loop)
    --verify  | -v Enable validatioin function, defalut: disable
    --rerun   | -r Rerun after failure, the max. rerun is 5 times, default: disable
    --save    | -s Save to file log, filename: {test case}_{year_month_day}.log, default: disable
    --help    | -h Help
```
