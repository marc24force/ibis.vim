let s:state = "Start"
let g:ibis_debug_print = 1

function! ibis#loop()
  call ibis#utils#dlog("[STATE] = " . s:state)
  if s:state == "Start"
    call s:start_state()
  elseif s:state == "Login"
    call s:login_state()
  endif
endfunction

function! ibis#update(signal)
  call ibis#utils#dlog("[CMD] = " . a:signal)
  if s:state == "Start"
    if a:signal == "Done" || a:signal == "Exists"
      let s:state = "Login"
    endif
  elseif s:state == "Start"
  endif
  call ibis#loop()
endfunction

function! s:start_state()
  if !filereadable(expand(g:ibis_profile_path) . "/profile")
    "Create profile
    call ibis#profile#new()
  else
    call ibis#update("Exists")
  endif
endfunction

function! s:login_state()
  let l:open = ibis#profile#open(g:ibis_profile_default)
  call ibis#utils#log(json_encode(l:open))
endfunction
