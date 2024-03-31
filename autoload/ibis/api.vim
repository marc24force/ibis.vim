let s:dir = expand("<sfile>:h:h:h")
let s:path = resolve(s:dir . "/api.py")
let s:job = v:null

function! ibis#api#start()
  let s:job = ibis#job#start(s:path, function("s:handle_data"))
  if g:ibis_logging == 0
    call ibis#job#send(s:job, {"type" : "nolog"})
  endif
endfunction

function! s:handle_data(data_raw)
  if empty(a:data_raw) | return | endif
  let data = json_decode(a:data_raw)

  if !data.success
    return ibis#utils#elog("api: " . string(data.error))
  endif

  if data.type == "login"
    call ibis#cache#write("folders", data.folders)
    call ibis#utils#log("Logged in!")
  elseif data.type == "select-folder"
    call ibis#cache#write("folder", data.folder)
    call ibis#cache#write("seq", data.seq)
    call ibis#cache#write("page", 0)
    call ibis#cache#write("emails", data.emails)
    call ibis#ui#list_email()
    call ibis#utils#log(data.msg)
  elseif data.type == "fetch-emails"
    call ibis#cache#write("emails", data.emails)
    let l:page = ibis#cache#read("page", 0)
    call ibis#ui#list_email()
    call ibis#utils#log(data.msg)

  endif
endfunction

function! ibis#api#login(profile)
  let l:imap_pswd = (a:profile["imap_pswd"] == "") ? ibis#ui#prompt_passwd("Input IMAP password: ") : a:profile["imap_pswd"]
  let l:smtp_pswd = (a:profile["smtp_pswd"] == "") ? ibis#ui#prompt_passwd("Input SMTP password: ") : a:profile["smtp_pswd"]
  if l:smtp_pswd == ""
    let l:smtp_pswd = l:imap_pswd
  endif
  call ibis#utils#log("Logging in...")
  let l:data = {
        \"type"       : "login",
        \"imap-host"  : a:profile["imap_host"],
        \"imap-port"  : a:profile["imap_port"],
        \"imap-login" : a:profile["imap_login"],
        \"imap-pswd"  : l:imap_pswd,
        \"smtp-host"  : a:profile["smtp_host"],
        \"smtp-port"  : a:profile["smtp_port"],
        \"smtp-login" : a:profile["smtp_login"],
        \"smtp-pswd"  : l:smtp_pswd}
  call ibis#job#send(s:job, l:data)
endfunction

function! ibis#api#select_folder(folder)
  call ibis#utils#log("Selecting folder...")
  let l:data = {"type": "select-folder", "folder": a:folder, "chunk-size": g:ibis_emails_chunk_size}
  call ibis#job#send(s:job, l:data)
endfunction

function! ibis#api#fetch_all_emails()
  let page = ibis#cache#read("page", 0)

  call ibis#utils#log("Fetching emails...")
  let l:data = {
    \"type": "fetch-emails",
    \"page": page,
    \"chunk-size": g:ibis_emails_chunk_size,
  \}
  call ibis#job#send(s:job, l:data)
endfunction

function! ibis#api#prev_page_emails()
  let page = ibis#cache#read("page", 0) - 1
  if page < 0 | let page = 0 | endif
  call ibis#cache#write("page", page)

  call ibis#utils#log("Fetching previous page...")
  let l:data = {
    \"type": "fetch-emails",
    \"page": page,
    \"chunk-size": g:ibis_emails_chunk_size,
  \}
  call ibis#job#send(s:job, l:data)
endfunction

function! ibis#api#next_page_emails()
  let page = ibis#cache#read("page", 0) + 1
  call ibis#cache#write("page", page)

  call ibis#utils#log("Fetching next page...")
  let l:data = {
    \"type": "fetch-emails",
    \"page": page,
    \"chunk-size": g:ibis_emails_chunk_size,
  \}
  call ibis#job#send(s:job, l:data)
endfunction
