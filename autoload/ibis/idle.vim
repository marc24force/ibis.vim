let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/idle.py")
let s:job = v:null

function! ibis#idle#start()
  let s:job = ibis#job#start(s:path, function("s:handle_data"))
endfunction

function! s:handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return ibis#utils#elog("idle: " . string(data.error))
  endif
endfunction

function! s:send(data)
  call ibis#job#send(s:job, a:data)
endfunction

function! ibis#idle#login(passwd)
  call s:send({
    \"type": "login",
    \"imap-host": g:ibis_imap_host,
    \"imap-port": g:ibis_imap_port,
    \"imap-login": g:ibis_imap_login,
    \"imap-passwd": a:passwd,
    \"idle-timeout": g:ibis_idle_timeout,
  \})
endfunction
