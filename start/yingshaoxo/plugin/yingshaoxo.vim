if !has("python3")
  echo "vim has to be compiled with +python3 to run this yingshaoxo_code_pilot"
  finish
endif

let s:_yingshaoxo_the_vim_script_path = expand('<sfile>:p')

py3 << EOF
import os
import vim

vim_script_path = vim.eval('s:_yingshaoxo_the_vim_script_path')
vim_script_folder_path = os.path.dirname(vim_script_path)
sys.path.insert(0, vim_script_folder_path)

import lib
EOF

function! Complete_the_rest()
py3 << EOF
lib.complete_the_rest()
EOF
"startinsert
endfunction

function! Complete_with_codet5()
py3 << EOF
lib.complete_with_codet5()
EOF
endfunction

nnoremap <C-S-P> <Esc>:call Complete_the_rest()<CR>
inoremap <C-S-P> <Esc>:call Complete_the_rest()<CR>

nnoremap <S-Tab> <Esc>:call Complete_with_codet5()<CR>
inoremap <S-Tab> <Esc>:call Complete_with_codet5()<CR>
