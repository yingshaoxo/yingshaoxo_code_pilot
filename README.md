# yingshaoxo_code_pilot
It is an offline 'AI' code completion tool made for vim.

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
