let s:ibis_blank_profile = {"profile_name":"Profile1","imap_host":"imap.example.com","imap_port":993,"imap_login":"user1","imap_pswd":"","smtp_host":"smtp.example.com","smtp_port":587,"smtp_login":"user1","smtp_pswd":"","name":"Your Name","mail":"your.name@example.com"}
let s:EditorBuffName = "Profile Editor"

function! s:editor_text(profile)
  call append(00, "Set-up your e-mail profile. Modify the values between [ ], all text outside of it will be ignored." .
                \ "Do not remove any lines either!")
  call append(01, "Leaving IMAP and SMTP passwords blanks will prompt for them when login in. " .
                \ "Otherwise the password is stored in the profile file located at 'g:ibis_profile_path'.")
  call append(02, "If only one password is set, both IMAP and SMTP will use the same one.")
  call append(03, "If you have the encryption for the profile file enabled, you will be prompted for it when confirming.")
  call append(04, "__________________________________________________")
  call append(05, "")
  call append(06, "Profile name: [" . a:profile["profile_name"] . "]")
  call append(07, "E-mail:  [" . a:profile["mail"] . "]")
  call append(08, "Your name: [" . a:profile["name"] . "]")
  call append(09, "")
  call append(10, "IMAP configuration")
  call append(11, "IMAP login: [" . a:profile["imap_login"] . "]")
  call append(12, "IMAP host: [" . a:profile["imap_host"] . "]")
  call append(13, "IMAP port: [" . a:profile["imap_port"] . "]")
  call append(14, "IMAP password: []")
  call append(15, "")
  call append(16, "SMTP configuration")
  call append(17, "SMTP login: [" . a:profile["smtp_login"] . "]")
  call append(18, "SMTP host: [" . a:profile["smtp_host"] . "]")
  call append(19, "SMTP port: [" . a:profile["smtp_port"] . "]")
  call append(20, "SMTP password: []")
  call cursor(7,16) "To edit profile name
  call deletebufline('%',line('$'))
endfunction

function! ibis#profile#new()
  " Check if the buffer with the specified name already exists
  if buflisted(s:EditorBuffName) && bufloaded(s:EditorBuffName)
    " If the buffer exists, switch to it
    execute 'buffer ' . bufnr(s:EditorBuffName)
  else
    call ibis#profile#edit(s:ibis_blank_profile)
  endif
endfunction

function! ibis#profile#edit(profile)
  if buflisted(s:EditorBuffName) && bufloaded(s:EditorBuffName)
    execute 'bwipeout ' . bufnr(s:EditorBuffName)
  endif
  " Create a new empty buffer
  enew
  " Set the buffer name
  execute 'file ' . s:EditorBuffName
  " Set the filetype 
  setfiletype IbisProfileEdit
  " Set the contents
  call s:editor_text(a:profile)
endfunction

function! ibis#profile#read()
  let l:profile_file = expand(g:ibis_profile_path) . "/profile"
  if filereadable(l:profile_file)
    let l:read = join(readfile(l:profile_file))
    if g:ibis_profile_encrypted == 1
      let l:read = ibis#utils#decrypt(l:read)
    endif
    return json_decode(l:read)
  else
    "Throw error
    call ibis#utils#elog("Could not find profile file")
    return ["ERROR"]
  endif
endfunction

function! s:json_format(file)
  call system(ibis#utils#mprintf(g:ibis_json_format_tool, a:file))
endfunction

function! ibis#profile#write(string)
  let l:profile_file = expand(g:ibis_profile_path) . "/profile"
  if g:ibis_profile_encrypted == 1
    let l:encrypted = ibis#utils#encrypt(a:string)
    call writefile([l:encrypted], l:profile_file)
  else 
    call writefile([a:string], l:profile_file)
    call s:json_format(l:profile_file)
  endif
endfunction

function! ibis#profile#touch()
  let l:profile_file = expand(g:ibis_profile_path) . "/profile"
  if !filereadable(l:profile_file)
    call ibis#profile#write("[]")
  endif
endfunction

function! s:get_field(line)
  return substitute(getline(a:line), '.*\[\(.*\)\].*', '\1', '')
endfunction

function! ibis#profile#save()
  "Check passwords
  let l:imap_pswd = s:get_field(15)
  let l:smtp_pswd = s:get_field(21)
  if l:imap_pswd == "" 
    let l:imap_pswd = l:smtp_pswd
  elseif l:smtp_pswd == "" 
    let l:smtp_pswd = l:imap_pswd
  endif
  "Create profile
  let l:new_profile = {"profile_name":s:get_field(7),
                      \"imap_host"   :s:get_field(13),
                      \"imap_port"   :s:get_field(14),
                      \"imap_login"  :s:get_field(12),
                      \"imap_pswd"   :l:imap_pswd,
                      \"smtp_host"   :s:get_field(19),
                      \"smtp_port"   :s:get_field(20),
                      \"smtp_login"  :s:get_field(18),
                      \"smtp_pswd"   :l:smtp_pswd,
                      \"name"        :s:get_field(9),
                      \"mail"        :s:get_field(8)}

  "If not exists, create empty file
  call ibis#profile#touch()

  let l:profiles = ibis#profile#read()

  "check no profile already exists with profile_name
  if empty(s:find_profile(l:profiles, l:new_profile["profile_name"])) 
    call add(l:profiles, l:new_profile)
    call ibis#profile#write(json_encode(l:profiles))
    bw!
    call ibis#update("Done")
  else
    call ibis#utils#elog("Profile with that name already exists!")
  endif
endfunction

function! s:find_profile(list, name)
    for prf in a:list
        if prf["profile_name"] == a:name
            return prf
        endif
    endfor
    return {}
endfunction

function! ibis#profile#open(name)
  let l:profiles = ibis#profile#read()
  let l:find = s:find_profile(l:profiles, a:name)
  if a:name != "" && !empty(l:find)
    return l:find
  else
    return l:profiles[0]
  endif
endfunction
