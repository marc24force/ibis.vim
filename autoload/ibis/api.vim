let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/api.py")
let s:job = v:null

function! ibis#api#start()
  let s:job = ibis#job#start(s:path, function("s:handle_data"))
endfunction

function! s:handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return ibis#utils#elog("api: " . string(data.error))
  endif

  if data.type == "login"
    call ibis#utils#log("Logged in!")
  endif
endfunction

function! ibis#api#login(profile)
  call ibis#utils#log("Logging in...")
  let l:data = {
        \"type"       : "login",
        \"imap-host"  : a:profile["imap_host"],
        \"imap-port"  : a:profile["imap_port"],
        \"imap-login" : a:profile["imap_login"],
        \"imap-pswd"  : a:profile["imap_pswd"],
        \"smtp-host"  : a:profile["smtp_host"],
        \"smtp-port"  : a:profile["smtp_port"],
        \"smtp-login" : a:profile["smtp_login"],
        \"smtp-pswd"  : a:profile["smtp_pswd"]}
  call ibis#job#send(s:job, l:data)

endfunction
