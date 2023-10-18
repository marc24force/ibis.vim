function! IrisThreadFold(lnum)
  return getline(a:lnum)[0] == ">"
endfunction

setlocal buftype=nofile
setlocal cursorline
setlocal foldexpr=IrisThreadFold(v:lnum)
setlocal foldlevel=0
setlocal foldlevelstart=0
setlocal foldmethod=expr
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(ibis-reply-email)      :call ibis#ui#reply_email()    <cr>
nnoremap <silent> <plug>(ibis-reply-all-email)  :call ibis#ui#reply_all_email()<cr>
nnoremap <silent> <plug>(ibis-forward-email)    :call ibis#ui#forward_email()  <cr>

call ibis#utils#define_maps([
  \["n", "gr", "reply-email"    ],
  \["n", "gR", "reply-all-email"],
  \["n", "gf", "forward-email"  ],
\])
