let s:key = ""
let s:key_set = 0

function! ibis#utils#encrypt(string)
  if s:key_set == 0
    let s:key = ibis#ui#prompt_passwd()
    let s:key_set = 1
  endif
  let l:enc_func = printf(g:ibis_profile_enc_func, s:key)
  let l:string = substitute(a:string, '"', '\\"', 'g')
  let l:encrypted = system('echo "' . l:string . '" | ' . l:enc_func)
  return l:encrypted
endfunction

function! ibis#utils#decrypt(string)
  if s:key_set == 0
    let s:key = ibis#ui#prompt_passwd()
  endif
  let l:dec_func = printf(g:ibis_profile_dec_func, s:key)
  let l:decrypted = system('echo "' . a:string . '" | ' . l:dec_func)
  return l:decrypted
endfunction

function! ibis#utils#pipe(...)
  let funcs = map(copy(a:000), "function(v:val)")
  return function("s:pipe", [funcs])
endfunction

function! s:pipe(funcs, arg)
  let data = a:arg
  for Fn in a:funcs
    let data = Fn(data)
  endfor
  return data
endfunction

function! ibis#utils#trim(str)
  return ibis#utils#pipe("s:trim_left", "s:trim_right")(a:str)
endfunction

function! s:trim_left(str)
  return substitute(a:str, '^\s*', "", "g")
endfunction

function! s:trim_right(str)
  return substitute(a:str, '\s*$', "", "g")
endfunction

function! ibis#utils#dlog(msg)
  if g:ibis_debug_print == 1
    call ibis#utils#log(a:msg)
  endif
endfunction

function! ibis#utils#log(msg)
  let msg = printf("Ibis: %s", a:msg)
  redraw | echom msg
endfunction

function! ibis#utils#elog(msg)
  let msg = printf("Ibis: %s", a:msg)
  redraw | echohl ErrorMsg | echom msg | echohl None
endfunction

function! ibis#utils#mprintf(format, arg)
  let l:num = len(split(a:format, '%s', 1)) - 1
  let l:args = repeat('"' . a:arg . '", ', l:num - 1) . '"' . a:arg . '"'
  execute 'return printf("'. a:format . '", '. l:args .')'
endfunction
