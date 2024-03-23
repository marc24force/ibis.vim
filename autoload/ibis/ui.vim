

function! ibis#ui#prompt_passwd()
  return ibis#utils#pipe("inputsecret", "ibis#utils#trim")("Input Ibis password: ")
endfunction
