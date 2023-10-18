let s:cache = {}

function! ibis#cache#read(key, default_val)
  return copy(has_key(s:cache, a:key) ? s:cache[a:key] : a:default_val)
endfunction

function! ibis#cache#write(key, val)
  let s:cache[a:key] = copy(a:val)
endfunction
