# yingshaoxo_code_pilot
It is an offline 'AI' code completion tool made for vim.

> For now, this plugin will only use current folder source code as the data for auto_completion.

> **It is based on Python3.10.4**, check your vim's python version: `:python3 import sys; print(sys.version)`. As I tested it out, it will not work on 3.7.3, a 3 years ago python, because it does not have type annotation. **I think we should try to write some python code that could work at least 10 years than 3 years. Otherwise, it would end like javascript, which code will not survive after 3 months. It's dependencies chain will be broken.**

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

## If it's not work
You can create your own version of VIM according to my guide:
```
0. use 0 third_party packages, use less python built-in module since they may not exists on new python implementation in other programming language
1. first, read the second command line paramater as txt file path
2. read text from that txt file
3. display it after call os.system("clear")
4. listen on keyboard j,k,l,h,dd,b,w,i,esc,:ZZ,:ZQ, do operations accordingly by sending signal to tty console
5. add more operations like shift+^,v+selection,yy,p
6. add readme docs for new vim clone
7. create a new code_pilot extension as a callback handler function when user using vim_clone, all we have to do is 'import our_extension_module; Global_Extension_List.append(our_module.handle_operation)', when user do operations, the new_vim will call functions in Global_Extension_List with some input_data; don't forget to use try_catch when loop Global_Extension_List

Author: yingshaoxo
```

## If it's not work 2
I have a good idea: 

You can simply have a shell program or webpage, where the user can paste a line of code, which might be a function name with partial arguments.

What you need to do is search the source code, find the most similar function, return its documentation or example.

Problem solved. 

Since you only use this feature a few times per day, so this is a good design.

<!--
## Todo List (may never complish)
* Make a pure python service that only have two API: `scan_folder(path)` and `generate_code(previous_code)->list[str]`
* In vim plugin, we simply call the two functions to: 1. scan current file parent folder. 2. do code generation,
* Integrade https://huggingface.co/Salesforce/codet5p-220m-py

To achive that, you should have a command line to launch a server, for example `yingshaoxo_code_pilot`

And it should have some commands like `yingshaoxo_code_pilot start`, `yingshaoxo_code_pilot start_with_codet5`, `yingshaoxo_code_pilot shell`, `yingshaoxo_code_pilot scan *`

> I suddently realize the server can get launched in vim script when user start edit a file. Just do a service port check, if it exists, do not launch service. if it not exists, launch service. And in the same python script, you also expose client functions, so the vim script can call when user hit some keys.
-->
