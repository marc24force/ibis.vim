
function! ibis#ui#prompt_passwd(msg)
  return ibis#utils#pipe("inputsecret", "ibis#utils#trim")(a:msg)
endfunction
