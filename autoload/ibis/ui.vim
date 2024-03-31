let s:config = {
  \"list.from": {
    \"columns": ["flags", "from", "subject", "date"],
  \},
  \"list.to": {
    \"columns": ["flags", "to", "subject", "date"],
  \},
  \"labels": {
    \"from": "FROM",
    \"to": "TO",
    \"subject": "SUBJECT",
    \"date": "DATE",
    \"flags": "FLAGS",
  \},
\}

function! ibis#ui#prompt_passwd(msg)
  return ibis#utils#pipe("inputsecret", "ibis#utils#trim")(a:msg)
endfunction

function! ibis#ui#select_folder()
  let folder  = ibis#cache#read("folder", "INBOX")
  let folders = ibis#cache#read("folders", [])

  if &rtp =~ "fzf.vim"
    call fzf#run({
      \"source":  folders,
      \"sink": function("ibis#api#select_folder"),
      \"down": "25%",
    \})
  else
    echo join(map(copy(folders), "printf('%s (%0d)', v:val, v:key)"), ", ") . ": "
    if len(folders) > 10
      let choice = ibis#utils#getnchar(2)
    else
      let choice = nr2char(getchar())
    endif
    call ibis#api#select_folder(folders[choice])
  endif
endfunction

function! ibis#ui#list_email()
  redraw | echo
  let folder = ibis#cache#read("folder", "INBOX")
  let emails = ibis#cache#read("emails", [])
  let template = printf("list.%s", folder == "Sent" ? "to" : "from")

  silent! bdelete Ibis
  silent! edit Ibis

  call append(0, s:render(template, emails))
  normal! ddgg
  setlocal filetype=ibis-list
endfunction

function! ibis#ui#preview_email(email, format)
  if a:format == "text"
    let email = substitute(a:email, "", "", "g")

    silent! bdelete Ibis\ preview
    silent! edit Ibis preview
    call append(0, split(email, "\n"))
    normal! ddgg
    setlocal filetype=ibis-preview

  elseif a:format == "html"
    let url = a:email
    execute "python3 import webbrowser; webbrowser.open_new('".url."')"
  endif
endfunction

function! ibis#ui#new_email()
  silent! bdelete Ibis\ new
  silent! edit Ibis new

  call append(0, [
    \"To: ",
    \"Cc: ",
    \"Bcc: ",
    \"Subject: ",
    \"",
  \])

  normal! ddgg$

  setlocal filetype=ibis-edit
  let &modified = 0
endfunction

function! ibis#ui#reply_email()
  let index = ibis#cache#read("email:index", 0)
  let email = ibis#cache#read("emails", [])[index]
  let message = map(getline(1, "$"), "'>' . v:val")

  if empty(email["reply-to"])
    let reply_to = email["from"]
  else
    let reply_to = email["reply-to"]
  endif

  silent! bdelete Ibis\ reply
  silent! edit Ibis reply

  call append(0, [
    \"In-Reply-To: " . email["message-id"],
    \"To: " . reply_to,
    \"Cc: ",
    \"Bcc: ",
    \"Subject: Re: " . email.subject,
    \"",
  \] + message)

  normal! dd6G

  setlocal filetype=ibis-edit
  let &modified = 0
endfunction

function! ibis#ui#reply_all_email()
  let index = ibis#cache#read("email:index", 0)
  let email = ibis#cache#read("emails", [])[index]
  let message = map(getline(1, "$"), "'>' . v:val")

  if empty(email["reply-to"])
    let reply_to = email["from"]
  else
    let reply_to = email["reply-to"]
  endif

  silent! bdelete Ibis\ reply\ all
  silent! edit Ibis reply all

  call append(0, [
    \"In-Reply-To: " . email["message-id"],
    \"To: " . reply_to,
    \"Cc: " . (has_key(email, "cc") ? email.cc : ""),
    \"Bcc: " . (has_key(email, "bcc") ? email.bcc : ""),
    \"Subject: Re: " . email.subject,
    \"",
  \] + message)

  normal! dd6G

  setlocal filetype=ibis-edit
  let &modified = 0
endfunction

function! ibis#ui#forward_email()
  let index = ibis#cache#read("email:index", 0)
  let email = ibis#cache#read("emails", [])[index]
  let message = getline(1, "$")

  silent! bdelete Ibis\ forward
  silent! edit Ibis forward

  call append(0, [
    \"To: ",
    \"Cc: ",
    \"Bcc: ",
    \"Subject: Fwd: " . email.subject,
    \"",
    \"---------- Forwarded message ---------",
  \] + message)

  normal! ddgg$

  setlocal filetype=ibis-edit
  let &modified = 0
endfunction

function! ibis#ui#save_email()
  call ibis#cache#write("draft", getline(1, "$"))
  call ibis#utils#log("draft saved!")
  let &modified = 0
endfunction

function! ibis#ui#send_email()
  redraw | echo
  let draft = ibis#cache#read("draft", [])

  let separator_idx = index(draft, "")

  let headers = {}
  for header in draft[:separator_idx-1]
    let header_split = split(header, ":")
    let key = header_split[0]
    let val = ibis#utils#trim(join(header_split[1:], ''))
    if !empty(val) | let headers[key] = val | endif
  endfor

  let message = join(draft[separator_idx+1:], "\r\n")

  silent! bdelete
  call ibis#api#send_email({
    \"headers": headers,
    \"message": message,
    \"from": {
      \"name": g:ibis_name,
      \"email": g:ibis_mail,
    \}
  \})
endfunction

function! s:render(type, lines)
  let s:max_widths = s:get_max_widths(a:lines, s:config[a:type].columns)
  let header = [s:render_line(s:config.labels, s:max_widths, a:type)]
  let line = map(copy(a:lines), "s:render_line(v:val, s:max_widths, a:type)")

  return header + line
endfunction

function! s:render_line(line, max_widths, type)
  return "|" . join(map(
    \copy(s:config[a:type].columns),
    \"s:render_cell(a:line[v:val], a:max_widths[v:key])",
  \), "")
endfunction

function! s:render_cell(cell, max_width)
  let cell_width = strdisplaywidth(a:cell[:a:max_width-1])
  return a:cell[:a:max_width-1] . repeat(" ", a:max_width - cell_width) . " |"
endfunction

function! s:get_max_widths(lines, columns)
  let max_widths = map(copy(a:columns), "strlen(s:config.labels[v:val])")

  for line in a:lines
    let widths = map(copy(a:columns), "strlen(line[v:val])")
    call map(max_widths, "max([widths[v:key], v:val])")
  endfor

  let tbl_width = ibis#utils#sum(max_widths) + len(max_widths) * 2 + 1
  let win_width = winwidth(0)
  let num_width = (&number || &relativenumber) ? &numberwidth : 0
  let diff_width = tbl_width - win_width + num_width 

  if diff_width >= 0
    let to_column_idx = index(s:config["list.to"]["columns"], "to")
    let to_column_diff = max_widths[to_column_idx] - win_width/6
    let max_widths[to_column_idx] -= to_column_diff
    let subject_column_idx = index(s:config["list.to"]["columns"], "subject")
    let subject_column_diff = diff_width - to_column_diff
    let max_widths[subject_column_idx] -= subject_column_diff
  elseif diff_width < 0
    let subject_column_idx = index(s:config["list.to"]["columns"], "subject")
    let max_widths[subject_column_idx] -= diff_width 
  endif
  echom max_widths

  return max_widths
endfunction

function! s:get_focused_email()
  let emails = ibis#cache#read("emails", [])
  let index = line(".") - 2
  if  index < 0 | throw "email not found" | endif
  
  return emails[index]
endfunction

