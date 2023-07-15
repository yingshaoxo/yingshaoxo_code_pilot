function! Complete_the_rest()
py3 << EOF
import vim
import re
from time import sleep

from auto_everything.terminal import Terminal
terminal = Terminal()

from auto_everything.disk import Disk
disk = Disk()

from auto_everything.ml import Yingshaoxo_Text_Generator

current_working_directory = terminal.run_command("pwd")
current_file_type = vim.eval("expand('%:e')")
seperator = "\n\n\n"

def complete_the_rest():
    print("I'm in working, please wait...")

    lines = vim.current.buffer[:]

    current_line_index = int(vim.eval('line(".")')) - 1
    current_line = lines[current_line_index]
    #print(current_line_index)

    previous_text = "\n".join(lines[: current_line_index+1])
    previous_text = previous_text.split(seperator)[-1].strip()
    #print(previous_text)

    found = Yingshaoxo_Text_Generator.next_code_generation(data_source_folder_path="~", input_text=previous_text, type_limiter=["."+current_file_type, ".md"], how_long_the_text_you_want_to_get=8192)

    found = found.split(seperator)[0]
    #print(found)
    splits = found.split("\n")
    vim.current.line += splits[0]
    for index, line in enumerate(splits[1:]):
        vim.current.buffer.append(line, current_line_index+index+1)

    print("Done.")

complete_the_rest()
EOF

"startinsert

endfunction

nnoremap <S-Tab> <Esc>:call Complete_the_rest()<CR>
inoremap <S-Tab> <Esc>:call Complete_the_rest()<CR>
