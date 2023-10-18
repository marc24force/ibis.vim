let s:contacts_path = resolve(expand("<sfile>:h:h") . '/.contacts')
let s:contacts = readfile(s:contacts_path)

function! IrisContactsComplete(findstart, base)
  if (a:findstart == 1)
    normal b
    return col(".") - 1
  else
    return filter(copy(s:contacts), printf("v:val =~ '.*%s.*'", a:base))
  endif
endfunction

function! IrisThreadFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=acwrite
setlocal completefunc=IrisContactsComplete
setlocal cursorline
setlocal foldexpr=IrisThreadFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nowrap
setlocal omnifunc=IrisContactsComplete
setlocal startofline

nnoremap <silent> <plug>(ibis-send-email) :call ibis#ui#send_email()<cr>

call ibis#utils#define_maps([
  \["n", "gs", "send-email"],
\])

augroup ibis
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call ibis#ui#save_email()
augroup end
