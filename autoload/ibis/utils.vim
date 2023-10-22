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

function! ibis#utils#assign(...)
  let overrides = copy(a:000)
  let base = remove(overrides, 0)

  for override in overrides
    for [key, val] in items(override)
      let base[key] = val
      unlet key val
    endfor
  endfor

  return base
endfunction

function! ibis#utils#sum(array)
  let total = 0

  for item in a:array
    let total += item
  endfor

  return total
endfunction

function! ibis#utils#log(msg)
  let msg = printf("Ibis: %s", a:msg)
  redraw | echom msg
endfunction

function! ibis#utils#elog(msg)
  let msg = printf("Ibis: %s", a:msg)
  redraw | echohl ErrorMsg | echom msg | echohl None
endfunction

function! ibis#utils#define_maps(maps)
  for [mode, key, plug] in a:maps
    let plug = printf("<plug>(ibis-%s)", plug)

    if !hasmapto(plug, mode)
      execute printf("%smap <nowait> <buffer> %s %s", mode, key, plug)
    endif
  endfor
endfunction

function! ibis#utils#getnchar(n)
  let l:number = a:n
  let l:string = ""

  while l:number > 0
    let l:string .= nr2char(getchar())
    let l:number -= 1
  endwhile

  return l:string
endfunction
