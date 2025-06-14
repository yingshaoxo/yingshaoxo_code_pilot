let s:plugin_path = expand('<sfile>:p')
let s:plugin_dir = fnamemodify(s:plugin_path, ':h')
let s:lib_path = s:plugin_dir . '/lib.py'

" Set preferred Python path
let s:preferred_python = '/home/python/use_docker_to_build_static_python3_binary_executable/data/Python-3.10.4/python'

" Detect Python version with preference
function! s:DetectPythonCmd()
    " Try preferred Python path first
    if filereadable(s:preferred_python)
        return s:preferred_python
    endif
    
    " Check for specific Python versions in order of preference
    let l:python_versions = [
        \ 'python3.10',
        \ 'python3.11',
        \ 'python3.9',
        \ 'python3.8',
        \ 'python3',
        \ 'python'
    \ ]
    
    for ver in l:python_versions
        if executable(ver)
            return ver
        endif
    endfor
    
    echohl ErrorMsg
    echo "No suitable Python installation found! Please install Python 3.10 or newer."
    echohl None
    return ''
endfunction

let s:python_cmd = s:DetectPythonCmd()
if s:python_cmd == ''
    finish
endif

" Get the current buffer content up to cursor
function! s:GetCurrentContent()
    let l:line = line('.')
    let l:col = col('.')
    let l:lines = getline(1, l:line - 1)
    let l:current_line = getline(l:line)[:l:col - 1]
    return join(l:lines + [l:current_line], "\n")
endfunction

function! Complete_the_rest()
    " Show status message
        echo "Completion in progress..."
    redraw
    
    let l:cwd = getcwd()
    let l:input_text = shellescape(s:GetCurrentContent())
    let l:cmd = printf('%s "%s" %s %s 512', s:python_cmd, s:lib_path, shellescape(l:cwd), l:input_text)
    
    let l:result = system(l:cmd)
    if v:shell_error == 0
        " Show success message
        echohl MoreMsg
        echo "=== Completion successful ==="
        echohl None
        
        " Get current line and cursor position
        let l:current_line = getline('.')
        let l:col = col('.')
        let l:line_num = line('.')
        
        " Split result into lines
        let l:completion_lines = split(l:result, '\n')
        
        if !empty(l:completion_lines)
            " Handle first line - append to current line
            let l:first_line = l:completion_lines[0]
            call setline('.', l:current_line[:l:col-1] . l:first_line)
            
            " Add remaining lines below if there are any
            if len(l:completion_lines) > 1
                call append(l:line_num, l:completion_lines[1:])
            endif
        endif
    else
        " Show error message
        echohl ErrorMsg
        echo "Completion failed: " . l:result
        echohl None
    endif
endfunction

" Key mappings for Alt+/ with multiple terminal compatibility options
" Standard Alt mapping
nnoremap <A-/> :call Complete_the_rest()<CR>
inoremap <A-/> <C-o>:call Complete_the_rest()<CR>

" Meta key mapping (some terminals send Meta instead of Alt)
nnoremap <M-/> :call Complete_the_rest()<CR>
inoremap <M-/> <C-o>:call Complete_the_rest()<CR>

" Escape sequence mapping (for terminals that send escape sequences)
nnoremap <Esc>/ :call Complete_the_rest()<CR>
inoremap <Esc>/ <C-o>:call Complete_the_rest()<CR>
