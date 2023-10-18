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
    call ibis#cache#write("folders", data.folders)
    call ibis#utils#log("logged in!")

  elseif data.type == "select-folder"
    call ibis#cache#write("folder", data.folder)
    call ibis#cache#write("seq", data.seq)
    call ibis#cache#write("page", 0)
    call ibis#cache#write("emails", data.emails)
    call ibis#ui#list_email()
    call ibis#utils#log("folder changed!")

  elseif data.type == "fetch-emails"
    call ibis#cache#write("emails", data.emails)
    call ibis#ui#list_email()
    redraw | echo

  elseif data.type == "fetch-email"
    call ibis#ui#preview_email(data.email, data.format)
    call ibis#utils#log("email previewed!")

  elseif data.type == "send-email"
    call ibis#cache#write("draft", [])
    call ibis#utils#log("email sent!")

  elseif data.type == "extract-contacts"
    call ibis#utils#log("contacts extracted!")

  elseif data.type == "download-attachments"
    let attachments_count = len(data.attachments)

    if attachments_count == 0
      call ibis#utils#log("no attachment found!")
    else
      call ibis#utils#log(printf("%d attachment(s) downloaded: %s", attachments_count, join(data.attachments, ", ")))
    endif
  endif
endfunction

function! s:send(data)
  call ibis#job#send(s:job, a:data)
endfunction

function! ibis#api#login(imap_passwd, smtp_passwd)
  call ibis#utils#log("logging in...")
  call s:send({
    \"type": "login",
    \"imap-host": g:ibis_imap_host,
    \"imap-port": g:ibis_imap_port,
    \"imap-login": g:ibis_imap_login,
    \"imap-passwd": a:imap_passwd,
    \"smtp-host": g:ibis_smtp_host,
    \"smtp-port": g:ibis_smtp_port,
    \"smtp-login": g:ibis_smtp_login,
    \"smtp-passwd": a:smtp_passwd,
  \})
endfunction

function! ibis#api#select_folder(folder)
  call ibis#utils#log("selecting folder...")
  call s:send({
    \"type": "select-folder",
    \"folder": a:folder,
    \"chunk-size": g:ibis_emails_chunk_size,
  \})
endfunction

function! ibis#api#fetch_all_emails()
  let seq = ibis#cache#read("seq", 0)
  let page = ibis#cache#read("page", 0)

  call ibis#utils#log("fetching emails...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq + page,
    \"chunk-size": g:ibis_emails_chunk_size,
  \})
endfunction

function! ibis#api#prev_page_emails()
  let seq = ibis#cache#read("seq", 0)
  let page = ibis#cache#read("page", 0) - 1
  if page < 0 | let page = 0 | endif
  call ibis#cache#write("page", page)

  call ibis#utils#log("fetching previous page...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq - (page * g:ibis_emails_chunk_size),
    \"chunk-size": g:ibis_emails_chunk_size,
  \})
endfunction

function! ibis#api#next_page_emails()
  let seq = ibis#cache#read("seq", 0)
  let page = ibis#cache#read("page", 0) + 1
  call ibis#cache#write("page", page)

  call ibis#utils#log("fetching next page...")
  call s:send({
    \"type": "fetch-emails",
    \"seq": seq - (page * g:ibis_emails_chunk_size),
    \"chunk-size": g:ibis_emails_chunk_size,
  \})
endfunction

function! ibis#api#preview_email(index, format)
  if a:index < 2 | return ibis#utils#elog("email not found") | endif

  let emails = ibis#cache#read("emails", [])
  let index = a:index - 2
  call ibis#cache#write("email:index", index)

  call ibis#utils#log(printf("previewing email in %s...", a:format))
  call s:send({
    \"type": "fetch-email",
    \"id": emails[index].id,
    \"format": a:format,
  \})
endfunction

function! ibis#api#download_attachments(index)
  if a:index < 2 | return ibis#utils#elog("email not found") | endif

  let emails = ibis#cache#read("emails", [])
  let index = a:index - 2

  call ibis#utils#log("downloading attachments...")
  call s:send({
    \"type": "download-attachments",
    \"id": emails[index].id,
    \"dir": g:ibis_download_dir,
  \})
endfunction

function! ibis#api#send_email(email)
  call ibis#utils#log("sending email...")
  call s:send(ibis#utils#assign(a:email, {
    \"type": "send-email",
  \}))
endfunction

function! ibis#api#add_flag(data)
  call s:send(ibis#utils#assign(a:data, {
    \"type": "add-flag",
  \}))
endfunction

function! ibis#api#extract_contacts()
  call ibis#utils#log("extracting contacts...")
  call s:send({"type": "extract-contacts"})
endfunction
