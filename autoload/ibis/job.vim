let s:editor = has("nvim") ? "neovim" : "vim8"

function! ibis#job#start(path, handle_data)
  execute "return ibis#job#" . s:editor . "#start(a:path, a:handle_data)"
endfunction

function! ibis#job#send(job, data)
  execute "call ibis#job#" . s:editor . "#send(a:job, a:data)"
endfunction

function! ibis#job#close(...)
  call ibis#utils#elog("job: connection lost")
endfunction
