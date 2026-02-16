" This was updated by github copilot
"
set encoding=utf-8
scriptencoding utf-8

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


function! s:new_GetCurrentContent()
    let l:line = line('.')
    let l:col = col('.')
    let l:lines = getline(1, l:line)
    let l:current_line = getline(l:line)[:l:col - 1]
    return join(l:lines + [l:current_line], "\n")
endfunction
function! Complete_the_rest_by_ask_llama()
    " Show status message
        echo "llama completion in progress..."
    redraw
    
    let l:cwd = getcwd()
    let l:input_text = shellescape(s:new_GetCurrentContent())
    let l:cmd = printf('%s "%s" %s %s 512 --mode ask_llama', s:python_cmd, s:lib_path, shellescape(l:cwd), l:input_text)
    
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
            call setline('.', l:current_line[:l:col+2] . l:first_line)
            
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

nnoremap <A-c> :call Complete_the_rest_by_ask_llama()<CR>
inoremap <A-c> <C-o>:call Complete_the_rest_by_ask_llama()<CR>
nnoremap <M-c> :call Complete_the_rest_by_ask_llama()<CR>
inoremap <M-c> <C-o>:call Complete_the_rest_by_ask_llama()<CR>
nnoremap <Esc>c :call Complete_the_rest_by_ask_llama()<CR>
inoremap <Esc>c <C-o>:call Complete_the_rest_by_ask_llama()<CR>


" Check if we have popup support
let s:has_popup = exists('*popup_create') && exists('*win_execute')
let s:is_neovim = has('nvim')

" Global variables for state
let s:popup_winid = 0
let s:popup_results = []
let s:current_selection = 0
let s:preview_bufnr = -1

function! s:ShowSearchResults(results)
    let s:popup_results = a:results
    let s:current_selection = 0
    
    " Store current window number and states
    let s:original_winnr = winnr()
    let s:original_modifiable = &l:modifiable
    let s:was_insert_mode = mode() == 'i'
    
    " If in insert mode, switch to normal mode first
    if s:was_insert_mode
        stopinsert
    endif
    
    " Format the display lines
    let l:display_lines = []
    let l:index = 0
    for result in a:results
        let l:preview = split(result.text, "\n")[0]
        let l:display = printf("[%d] %s:%d: %s", l:index + 1, fnamemodify(result.file, ':t'), result.line, l:preview)
        call add(l:display_lines, l:display)
        let l:index += 1
    endfor

    " Close any existing preview window
    silent! pclose
    
    " Create and set up the preview window content
    let l:tmpfile = tempname()
    call writefile(l:display_lines + ['', '--- Navigation Help ---', 'Up/Down or j/k: Navigate', 'Enter: Select code', 'Esc/q: Close window'], l:tmpfile)
    
    " Make sure we're in normal mode and the buffer is modifiable before any window operations
    if mode() != 'n'
        stopinsert
    endif
    
    " Switch to original window and make it modifiable
    execute s:original_winnr . "wincmd w"
    setlocal modifiable
    
    " Create the preview window
    execute 'silent! pedit ' . l:tmpfile
    
    " Switch to preview window
    wincmd P
    
    " Set window-specific options
    setlocal nonumber
    setlocal norelativenumber
    setlocal nofoldenable
    setlocal nomodifiable
    setlocal cursorline
    setlocal buftype=nofile
    setlocal bufhidden=wipe
    
    " Set up mappings for the preview window
    nnoremap <buffer> <silent> <CR> :call <SID>ApplySelectedCompletion()<CR>
    nnoremap <buffer> <silent> q :call <SID>ClosePreviewAndReturn()<CR>
    nnoremap <buffer> <silent> <ESC> :call <SID>ClosePreviewAndReturn()<CR>
    nnoremap <buffer> <silent> j :<C-u>call <SID>PreviewMove('j')<CR>
    nnoremap <buffer> <silent> k :<C-u>call <SID>PreviewMove('k')<CR>
    nnoremap <buffer> <silent> <Down> :<C-u>call <SID>PreviewMove('j')<CR>
    nnoremap <buffer> <silent> <Up> :<C-u>call <SID>PreviewMove('k')<CR>
    
    " Move cursor to first result
    normal! gg
endfunction

function! s:PreviewMove(direction)
    if a:direction == 'j'
        if line('.') < line('$') - 4  " Don't move into the help text
            normal! j
            call s:UpdatePreviewSelection()
        endif
    elseif a:direction == 'k'
        if line('.') > 1
            normal! k
            call s:UpdatePreviewSelection()
        endif
    endif
endfunction

function! s:ClosePreviewAndReturn()
    pclose
    " Return to original window
    execute s:original_winnr . "wincmd w"
    
    " Restore original modifiable state
    let &l:modifiable = s:original_modifiable
    
    " Return to insert mode if we were in it
    if s:was_insert_mode
        startinsert
    endif
endfunction

function! s:UpdatePreviewSelection()
    let s:current_selection = line('.') - 1
endfunction

function! s:PopupFilter(winid, key)
    if !s:has_popup
        return 0
    endif
    
    if a:key == "\<UP>" || a:key == 'k'
        let s:current_selection = max([0, s:current_selection - 1])
        call win_execute(a:winid, 'normal! k')
        return 1
    elseif a:key == "\<DOWN>" || a:key == 'j'
        let s:current_selection = min([len(s:popup_results) - 1, s:current_selection + 1])
        call win_execute(a:winid, 'normal! j')
        return 1
    elseif a:key == "\<CR>"
        call s:ApplySelectedCompletion()
        return 1
    elseif a:key == "\<ESC>"
        call popup_close(a:winid)
        return 1
    endif
    return 0
endfunction

function! s:PopupCallback(winid, result)
    let s:popup_winid = 0
endfunction

function! s:ApplySelectedCompletion()
    let l:selected_index = line('.') - 1
    
    if l:selected_index >= 0 && l:selected_index < len(s:popup_results)
        let l:selected = s:popup_results[l:selected_index]
        let l:lines = split(l:selected.text, "\n")
        
        " Return to original window first
        execute s:original_winnr . "wincmd w"
        
        " Ensure we're in normal mode for the modification
        if mode() != 'n'
            stopinsert
        endif
        
        " Set modifiable before making changes
        setlocal modifiable
        
        " Close preview window
        pclose
        
        if !empty(l:lines)
            " Apply the changes
            call setline('.', l:lines[0])
            if len(l:lines) > 1
                call append(line('.'), l:lines[1:])
            endif
        endif
        
        " Restore original modifiable state
        let &l:modifiable = s:original_modifiable
        
        " Return to insert mode if we were in it
        if s:was_insert_mode
            startinsert
        endif
    endif
endfunction

function! s:Search_similar_code()
    " Store the original mode
    let s:was_insert_mode = mode() == 'i'
    
    " If in insert mode, switch to normal mode first
    if s:was_insert_mode
        stopinsert
    endif
    
    let l:cwd = getcwd()
    let l:current_line = getline('.')
    
    " Skip if line is empty
    if empty(l:current_line)
        echo "Empty line, nothing to search"
        " Return to insert mode if we were in it
        if s:was_insert_mode
            startinsert
        endif
        return
    endif
    
    " Convert line to proper UTF-8 encoding if needed
    if &encoding != 'utf-8'
        let l:current_line = iconv(l:current_line, &encoding, 'utf-8')
    endif
    
    let l:cmd = printf('%s "%s" --mode search %s %s 512', s:python_cmd, s:lib_path, shellescape(l:cwd), shellescape(l:current_line))
    
    let l:result = system(l:cmd)
    if v:shell_error == 0
        let l:results = json_decode(l:result)
        if !empty(l:results)
            call s:ShowSearchResults(l:results)
        else
            echo "No matching code found"
            " Return to insert mode if we were in it
            if s:was_insert_mode
                startinsert
            endif
        endif
    else
        echohl ErrorMsg
        echo "Search failed: " . l:result
        echohl None
        " Return to insert mode if we were in it
        if s:was_insert_mode
            startinsert
        endif
    endif
endfunction

" Update the mappings to use the new function name
nnoremap <A-f> :call <SID>Search_similar_code()<CR>
inoremap <A-f> <C-o>:call <SID>Search_similar_code()<CR>

nnoremap <M-f> :call <SID>Search_similar_code()<CR>
inoremap <M-f> <C-o>:call <SID>Search_similar_code()<CR>

nnoremap <Esc>f :call <SID>Search_similar_code()<CR>
inoremap <Esc>f <C-o>:call <SID>Search_similar_code()<CR>
