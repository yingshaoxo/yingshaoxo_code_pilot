# yingshaoxo_code_pilot
It is an offline 'AI' code completion tool made for vim.

> For now, this plugin will only use current folder source code as the data for auto_completion.

## Install
```bash
curl -sSL https://raw.githubusercontent.com/yingshaoxo/yingshaoxo_code_pilot/main/install.sh | bash
```

First, `vim hi.txt`

Then hit `Shift + Tab` in non_insert mode.

## Usage
Just open a file, in non_insert mode, in the line you want to complete, hit `Shift + Tab`.

> By the way, vim has a built-in auto_complete command: `ctrl+p`

## Uninstall
```bash
rm -fr ~/.vim/pack/yingshaoxo_code_pilot
```

## Todo List
* Make a pure python service that only have two API: `scan_folder(path)` and `generate_code(previous_code)->list[str]`
* In vim plugin, we simply call the two functions to: 1. scan current file parent folder. 2. do code generation,
* Integrade https://huggingface.co/Salesforce/codet5p-220m-py

To achive that, you should have a command line to launch a server, for example `yingshaoxo_code_pilot`

And it should have some commands like `yingshaoxo_code_pilot start`, `yingshaoxo_code_pilot start_with_codet5`, `yingshaoxo_code_pilot shell`, `yingshaoxo_code_pilot scan *`

> I suddently realize the server can get launched in vim script when user start edit a file. Just do a service port check, if it exists, do not launch service. if it not exists, launch service. And in the same python script, you also expose client functions, so the vim script can call when user hit some keys.
