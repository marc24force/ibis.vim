  " Set the buffer to not be associated with a file
  setlocal nobuflisted buftype=acwrite wrap cursorline noconfirm

augroup ibis
  autocmd! * <buffer>
  autocmd  BufWriteCmd <buffer> call ibis#profile#save()
augroup end
