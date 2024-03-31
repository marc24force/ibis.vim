let s:state = "Start"
"Start -> initial state
"Create -> Profile create
"Edit -> Profile editor
"Client -> Normal execution
let s:profile = g:ibis_profile_default
let s:login = 0

function! ibis#loop()
  call ibis#utils#dlog("[STATE] = " . s:state)
  if s:state == "Start"
    call s:start_state()
  elseif s:state == "Create"
    call s:create_state()
  elseif s:state == "Client"
    call s:client_state()
  endif
endfunction

function! ibis#update(signal)
  call ibis#utils#dlog("[CMD] = " . a:signal)
  if s:state == "Start"
    if a:signal == "ProfileExists"
      let s:state = "Client"
    elseif a:signal == "MissingProfile"
      let s:state = "Create"
    endif
  elseif s:state == "Create"
    if a:signal == "ProfileSaved"
      let s:state = "Client"
    endif
  elseif s:state == "Client"
  endif
  call ibis#loop()
endfunction

function! s:start_state()
  call ibis#api#start()
  if !filereadable(expand(g:ibis_profile_path) . "/profile")
    call ibis#update("MissingProfile")
  else
    call ibis#update("ProfileExists")
  endif
endfunction

function! s:create_state()
  call ibis#profile#new()
endfunction

function! s:client_state()
  if s:login == 0
    let l:open = ibis#profile#open(s:profile)
    call ibis#api#login(l:open)
    call ibis#api#select_folder("INBOX")
    let s:login = 1
  else 
    call ibis#api#fetch_all_emails()
  endif
endfunction
