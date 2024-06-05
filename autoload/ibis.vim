let s:state = "Start"
"Start -> initial state
"Create -> Profile creator
"Logout -> Log out from loaded profile
"Logerr -> An error in Login occurred
"Login  -> Log in to loaded profile
"Client -> Normal execution

let s:next_profile = g:ibis_profile_default

function! ibis#loop()
  call ibis#utils#dlog("[STATE] = " . s:state)

  if s:state == "Start"
    call ibis#api#start()

  elseif s:state == "Create"
    call ibis#profile#new()

  elseif s:state == "Login"
    let l:open = ibis#profile#open(s:next_profile)
    call ibis#api#login(l:open)

  elseif s:state == "Client"
    call ibis#api#fetch_all_emails()

  elseif s:state == "Logout"
      silent! bd Ibis
      call ibis#api#logout()

  elseif s:state == "Logerr"
      call ibis#ui#list_email()

  endif
endfunction

function! ibis#update(signal, value)
  call ibis#utils#dlog("[CMD] = " . a:signal . "(". a:value . ")")
  if s:state == "Start"
    if a:signal == "ProfileExists"
      let s:state = "Login"
    elseif a:signal == "MissingProfile"
      let s:state = "Create"
    endif

  elseif s:state == "Create"
    if a:signal == "ProfileSaved"
      let s:next_profile = a:value
      let s:state = "Login"
    endif

  elseif s:state == "Login"
    if a:signal == "LoggedIn"
      let s:state = "Client"
    elseif a:signal == "Failed"
      let s:state = "Logerr"
    endif

  elseif s:state == "Client"
    if a:signal == "ProfileSelect"
      let s:next_profile = a:value
      let s:state = "Logout"
    elseif a:signal == "ProfileCreate"
      let s:state = "Create"
    endif

  elseif s:state == "Logout"
    if a:signal == "LoggedOut"
      let s:state = "Login"
    endif

  elseif s:state == "Logerr"
    if a:signal == "ProfileSelect"
      let s:next_profile = a:value
      let s:state = "Login"
    elseif a:signal == "ProfileCreate"
      let s:state = "Create"
    endif
  endif
  call ibis#loop()
endfunction
