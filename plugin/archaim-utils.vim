map <Leader>ar :Ar 
map <Leader>Ar viwy:Ar <C-r>" 
nnoremap <F2> :CocCommand pyright.organizeimports<cr>
nnoremap <F4> :call <SID>ARCHaimCurrentLineHighlight()<CR>

if !has('nvim')
  execute "set <M-k>=\ek"
  execute "set <M-j>=\ej"
endif

nnoremap <silent> <M-k> :Amlu(v:count)<cr>==
nnoremap <silent> <M-j> :Amld(v:count)<cr>==
inoremap <silent> <M-k> <c-o>:Amlu(v:count)<cr>==
inoremap <silent> <M-j> <c-o>:Amld(v:count)<cr>==
inoremap <silent> <c-j> <c-o>:call ARCHaimMoveWordBackwards()<cr>
inoremap <silent> <c-k> <c-o>:call ARCHaimMoveWordForward()<cr>
nnoremap <silent> <c-j> :call ARCHaimMoveWordBackwards()<cr>
nnoremap <silent> <c-k> :call ARCHaimMoveWordForward()<cr>
vnoremap <silent> <M-k> :'<,'>Ambu(v:count)<cr>gv
vnoremap <silent> <M-j> :'<,'>Ambd(v:count)<cr>gv
inoremap <tab> <c-o>:Aimti<cr>
inoremap <s-tab> <c-o>:Aimtu<cr>
nnoremap <tab> :Aimti<cr>
nnoremap <s-tab> :Aimtu<cr>
vnoremap <tab> >gv
vnoremap <s-tab> <gv

let g:au_rr_exclude_files = ".*.sw*"
let g:au_rr_exclude_dirs = "--exclude-dir=.idea --exclude-dir=.bzr --exclude-dir=,CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn"


" {{{ FOLDING


function! ARCHaimFZFAg(query)
  let l:ag_extra_parameters = ''
  let l:gitignore_global_path = $HOME . '/.gitignore_global'

  if filereadable(l:gitignore_global_path)
    let s:gitignore_global_lines = readfile($HOME . '/.gitignore_global')

    for s:line in s:gitignore_global_lines
      if (s:line == '' || s:line[0] == '#')
        continue
      endif

      let l:ag_extra_parameters .= ' --ignore "./' . s:line . '"'
    endfor
  endif

  call fzf#vim#ag(a:query, l:ag_extra_parameters, {'options': '--delimiter : --nth 4.. --reverse'})
endfunction


function! ARCHaimFZFExcludes()
  let l:fzf_extra_parameters = ''
  let l:exclude_arg_name = ' ! -path '

  if (match($FZF_DEFAULT_COMMAND, ' fd ') > -1)
    let l:exclude_arg_name = ' -E '
  endif

  if exists('g:archaim_fzf_extra_parameters')
    let l:fzf_extra_parameters .= g:archaim_fzf_extra_parameters
  endif

  for i in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    if (bufname(i) != '')
      let l:fzf_extra_parameters .= l:exclude_arg_name . '"./' . bufname(i) . '"'
    endif
  endfor

  let l:gitignore_global_path = $HOME . '/.gitignore_global'

  if filereadable(l:gitignore_global_path)
    let s:gitignore_global_lines = readfile($HOME . '/.gitignore_global')

    for s:line in s:gitignore_global_lines
      if (s:line == '' || s:line[0] == '#')
        continue
      endif

      let l:fzf_extra_parameters .= l:exclude_arg_name . '"./' . s:line . '"'
    endfor
  endif

  let $FZF_EXTRA_PARAMETERS = l:fzf_extra_parameters
endfunction


function! ARCHaimMoveLineUp(count) range
  if (a:count == 0)
    let l:count = 1
  else
    let l:count = a:count
  endif

  if (line('.') - l:count < 1)
    return
  endif

  let l:lines_to_move = l:count + 1
  exec ":m .-" . l:lines_to_move . "<cr>"
endfunction


function! ARCHaimMoveLineDown(count) range
  if (a:count == 0)
    let l:count = 1
  else
    let l:count = a:count
  endif

  exec ":m .+" . l:count . "<cr>"
endfunction


function! ARCHaimMoveBlockUp(count) range
  if (a:count == 0)
    let l:count = 1
  else
    let l:count = a:count
  endif

  let l:lines_to_move = l:count + 1
  exec ":'<,'>m '<-" . l:lines_to_move
endfunction


function! ARCHaimMoveBlockDown(count) range
  if (a:count == 0)
    let l:count = 1
  else
    let l:count = a:count
  endif

  exec ":'<,'>m '>+" . l:count
endfunction


function! ARCHaimReplaceRecurively(pattern_to_replace, pattern_replace_with)
  exec ":args `grep --exclude='" . g:au_rr_exclude_files . "' " . g:au_rr_exclude_dirs . " -R -l '" . a:pattern_to_replace . "'`"
  exec ":argdo %s/" . a:pattern_to_replace . "/" . a:pattern_replace_with . "/gc | update | :bd"
endfunction


function! ARCHaimPythonCleanImportLine()
  let l:line=getline('.')

  if (match(l:line, 'from\s\+.*\s\+import\s\+') > -1)
    silent! exec ':s/^from\s*/from /g'
    silent! exec ':s/\s*import\s*/ import /g'
    silent! exec ':s/^\s*import/import/g'
    silent! exec ':s/\(\w\),\(\w\)/\1, \2/g'
    silent! exec ':s/\(\w\),\s\s\+\(\w\)/\1, \2/g'
    silent! exec ':s/\s\+$//g'
    silent! exec "normal /import /e+1\<CR>v$hd"

    let l:import_items=join(sort(split(getreg('"'), '\s*,\s*')), ', ')

    if (len(l:import_items) > 0)
      exec ':call append(line("."), "' . l:import_items . '")'
      normal J
    endif
  else
    let l:init_line=line('.')
    let l:open_import_line=search('from\s\+.*\s\+import\s*(', 'bn')
    let l:closing_import_line=search(')', 'n')
    let l:prev_out_of_import_line=search('[^ _,A-Za-z0-9]', 'bn')
    let l:next_out_of_import_line=search('[^ _,A-Za-z0-9]', 'n')

    if (l:open_import_line == 0 || l:open_import_line < l:prev_out_of_import_line)
      echo "open_import_line: ".l:open_import_line.", prev_out_of_import_line: ".l:prev_out_of_import_line
      return 0
    endif

    if (l:closing_import_line > l:next_out_of_import_line)
      echo "closing_import_line: ".l:closing_import_line.", next_out_of_import_line: ".l:next_out_of_import_line
      return 0
    endif

    exec ":" . string(l:open_import_line + 1) . "," . string(l:closing_import_line - 1) . "sort u"
  endif
endfunction


function! ARCHaimMoveWordForward()
  let l:char = getline('.')[col('.') - 1]

  if (l:char == ')' || l:char == ']' || l:char == '}')
    silent! exec "normal xep"
  else
    let l:line_from_cursor = getline('.')[col('.') - 1:col('$')]

    if (match(l:line_from_cursor, '^\w\+, ') == -1)
      return
    endif

    silent! exec 'normal f xwPF,hdiwelpF,xt pe'
  endif
endfunction


function! ARCHaimMoveWordBackwards()
  let l:char = getline('.')[col('.') - 1]

  if (l:char == ')' || l:char == ']' || l:char == '}')
    silent! exec "normal xbP"
  else
    let l:line_before_cursor = getline('.')[0:col('.') - 1]

    if (match(l:line_before_cursor, ', \w\+$') == -1)
      return
    endif

    silent! exec 'normal F xbbPf,ldiwbbhPf,xF Pb'
  endif
endfunction


function! <SID>ARCHaimCurrentLineHighlight()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction


function! ARCHaimGetIndentString()
    let l:indent = ''

    if &expandtab
      let l:current_indent_size = 0

      while  l:current_indent_size < &shiftwidth
        let l:indent .= ' '
        let l:current_indent_size += 1
      endwhile
    else
      let l:indent = "\t"
    endif

    return l:indent
endfunction


function! ARCHaimIModeTabIndent()
  let l:new_position = col('.') + shiftwidth()
  let l:line=getline('.')

  if getline('.') == ''
    call setline('.', ARCHaimGetIndentString())
  else
    silent! exec 'normal >>'
  endif

  echom l:new_position
  call cursor(line('.'), l:new_position)
endfunction


function! ARCHaimIModeTabUnindent()
  let l:new_position = col('.') - shiftwidth()

  if l:new_position < 0
    let l:new_position = 0
  endif
  silent! exec 'normal <<'
  echom l:new_position
  call cursor(line('.'), l:new_position)
endfunction


" }}}


" {{{ FOLDING


command! -nargs=* Ar call ARCHaimReplaceRecurively(<f-args>)
command! -nargs=1 -range Amlu  <line1>,<line2>call ARCHaimMoveLineUp(<args>)
command! -nargs=1 -range Amld <line1>,<line2>call ARCHaimMoveLineDown(<args>)
command! -nargs=1 -range Ambu <line1>,<line2>call ARCHaimMoveBlockUp(<args>)
command! -nargs=1 -range Ambd <line1>,<line2>call ARCHaimMoveBlockDown(<args>)
command! -nargs=0 Aimti call ARCHaimIModeTabIndent()
command! -nargs=0 Aimtu call ARCHaimIModeTabUnindent()


" }}}
