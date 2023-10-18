let g:ibis_passwd_show_cmd = "gpg --decrypt --batch --no-tty -q '%s'"

let g:ibis_name   = get(g:, "ibis_name", "Ibis")
let g:ibis_email  = get(g:, "ibis_email", "ibis@localhost")
let g:ibis_mail   = get(g:, "ibis_mail", g:ibis_email)

let g:ibis_imap_host            = get(g:, "ibis_imap_host", "localhost")
let g:ibis_imap_port            = get(g:, "ibis_imap_port", 993)
let g:ibis_imap_login           = get(g:, "ibis_imap_login", g:ibis_mail)
let g:ibis_imap_passwd_filepath = get(g:, "ibis_imap_passwd_filepath", "")
let g:ibis_imap_passwd_show_cmd = get(g:, "ibis_imap_passwd_show_cmd", "")

let g:ibis_smtp_host            = get(g:, "ibis_smtp_host", g:ibis_imap_host)
let g:ibis_smtp_port            = get(g:, "ibis_smtp_port", 587)
let g:ibis_smtp_login           = get(g:, "ibis_smtp_login", g:ibis_mail)
let g:ibis_smtp_passwd_filepath = get(g:, "ibis_smtp_passwd_filepath", g:ibis_imap_passwd_filepath)
let g:ibis_smtp_passwd_show_cmd = get(g:, "ibis_smtp_passwd_show_cmd", g:ibis_imap_passwd_show_cmd)

let g:ibis_idle_enabled = get(g:, "ibis_idle_enabled", 1)
let g:ibis_idle_timeout = get(g:, "ibis_idle_timeout", 15)

let g:ibis_emails_chunk_size = get(g:, "ibis_emails_chunk_size", 50)

let g:ibis_download_dir = get(g:, "ibis_download_dir", "~/Downloads")

command! Ibis call ibis#start()
command! IbisFolder call ibis#ui#select_folder()
command! IbisExtractContacts call ibis#api#extract_contacts()
