let s:is_started = 0

function! ibis#start()
  if s:is_started == 0
    let imap_password = ibis#ui#prompt_passwd(
      \g:ibis_imap_passwd_filepath,
      \g:ibis_imap_passwd_show_cmd,
      \"IMAP password"
    \)

    let smtp_password = ibis#ui#prompt_passwd(
      \g:ibis_smtp_passwd_filepath,
      \g:ibis_smtp_passwd_show_cmd,
      \"SMTP password (empty=same as IMAP)"
    \)

    if smtp_password == ""
      let smtp_password = imap_password
    endif

    call ibis#api#start()
    call ibis#api#login(imap_password, smtp_password)
    call ibis#api#select_folder("INBOX")

    if g:ibis_idle_enabled
      call ibis#idle#start()
      call ibis#idle#login(imap_password)
    endif

    let s:is_started = 1
  else
    call ibis#api#fetch_all_emails()
  endif
endfunction
