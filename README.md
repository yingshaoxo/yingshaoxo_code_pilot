# yingshaoxo_code_pilot
It is an offline 'AI' code completion tool made for vim.

> For now, this plugin will only use current folder source code as the data for auto_completion.

## Install
### 1.Compile vim with dynamic python support (otherwise, you can't use python in vim and can't use YouCompleteMe)
```bash
git clone https://github.com/vim/vim.git
cd vim/src
./configure --with-features=huge --enable-python3interp=dynamic
make
sudo make install
```

### 2.Install yingshaoxo_code_pilot
```bash
curl -sSL https://raw.githubusercontent.com/yingshaoxo/yingshaoxo_code_pilot/main/install.sh | bash
```

## Usage
Just open a file `vim hi.txt`, in the line you want to complete, hit `Ctrl + Shift + P`.

> By the way, vim has a built-in auto_complete command: `ctrl+p`

> If you want to use a real AI version, use this in non_insert mode: `Shift + Tab`

## Uninstall
```bash
rm -fr ~/.vim/pack/yingshaoxo_code_pilot
```

<!--
## Todo List (may never complish)
* Make a pure python service that only have two API: `scan_folder(path)` and `generate_code(previous_code)->list[str]`
* In vim plugin, we simply call the two functions to: 1. scan current file parent folder. 2. do code generation,
* Integrade https://huggingface.co/Salesforce/codet5p-220m-py

To achive that, you should have a command line to launch a server, for example `yingshaoxo_code_pilot`

And it should have some commands like `yingshaoxo_code_pilot start`, `yingshaoxo_code_pilot start_with_codet5`, `yingshaoxo_code_pilot shell`, `yingshaoxo_code_pilot scan *`

> I suddently realize the server can get launched in vim script when user start edit a file. Just do a service port check, if it exists, do not launch service. if it not exists, launch service. And in the same python script, you also expose client functions, so the vim script can call when user hit some keys.
-->
