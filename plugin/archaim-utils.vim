map <Leader>ar :Ar 
map <Leader>Ar viwy:Ar <C-r>" 

let g:au_rr_exclude_files = ".*.sw*"
let g:au_rr_exclude_dirs = "--exclude-dir=.idea --exclude-dir=.bzr --exclude-dir=,CVS --exclude-dir=.git --exclude-dir=.hg --exclude-dir=.svn"


" {{{ FOLDING


function! ARCHaimReplaceRecurively(pattern_to_replace, pattern_replace_with)
  exec ":args `grep --exclude='" . g:au_rr_exclude_files . "' " . g:au_rr_exclude_dirs . " -R -l '" . a:pattern_to_replace . "'`"
  exec ":argdo %s/" . a:pattern_to_replace . "/" . a:pattern_replace_with . "/gc | update | :bd"
endfunction


" }}}


" {{{ FOLDING


command! -nargs=* Ar call ARCHaimReplaceRecurively(<f-args>)


" }}}
