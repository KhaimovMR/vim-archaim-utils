map <Leader>ar :Ar 
map <Leader>Ar viwy:Ar <C-r>" 
nnoremap <F2> :call ARCHaimPythonCleanImportLine()<cr>

let g:au_rr_exclude_files = ".*.sw*"
let g:au_rr_exclude_dirs = "--exclude-dir=.idea --exclude-dir=.bzr --exclude-dir=,CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn"


" {{{ FOLDING


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


" }}}


" {{{ FOLDING


command! -nargs=* Ar call ARCHaimReplaceRecurively(<f-args>)


" }}}
