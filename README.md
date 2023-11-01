# yingshaoxo_code_pilot
It is an offline 'AI' code completion tool made for vim.

> Don't use this if your computer has a lot of code. Instead, try to run this in a virtualbox machine. Start coding from 0, it would be much quicker for the codebase scanning. Because for current version, this software will scan "~" home folder to get source code, which may take a lot of time.

## Install
```bash
curl -sSL https://raw.githubusercontent.com/yingshaoxo/yingshaoxo_code_pilot/main/install.sh | bash
```

First, `vim hi.txt`

Then hit `Shift + Tab`

## Usage
Just open another file, in the line you want to complete, hit `Shift + Tab` again.

> If it raise some dependence error, you may want to run `pip uninstall auto_everything` first, then run the above curl install command again.

> By the way, vim has a built-in auto_complete command: `ctrl+p`

## Uninstall
```bash
rm -fr ~/.vim/pack/yingshaoxo_code_pilot
```

## Todo List
* Make a pure python service that only have two API: `scan_folder(path)` and `generate_code(previous_code)->list[str]`
* In vim plugin, we simply call the two functions to: 1. scan current file parent folder. 2. do code generation,
