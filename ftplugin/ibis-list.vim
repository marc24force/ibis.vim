setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(ibis-preview-text-email)   :call ibis#api#preview_email(line("."), "text")<cr>
nnoremap <silent> <plug>(ibis-preview-html-email)   :call ibis#api#preview_email(line("."), "html")<cr>
nnoremap <silent> <plug>(ibis-download-attachments) :call ibis#api#download_attachments(line(".")) <cr>
nnoremap <silent> <plug>(ibis-new-email)            :call ibis#ui#new_email()                      <cr>
nnoremap <silent> <plug>(ibis-prev-page-emails)     :call ibis#api#prev_page_emails()              <cr>
nnoremap <silent> <plug>(ibis-next-page-emails)     :call ibis#api#next_page_emails()              <cr>
nnoremap <silent> <plug>(ibis-select-folder)        :call ibis#ui#select_folder()                  <cr>
nnoremap <silent> <plug>(ibis-select-profile)       :call ibis#ui#select_profile()                 <cr>

call ibis#utils#define_maps([
  \["n", "<c-b>", "prev-page-emails"    ],
  \["n", "<c-f>", "next-page-emails"    ],
  \["n", "fs",    "select-folder"       ],
  \["n", "ps",    "select-profile"      ],
\])

"  \["n", "<cr>",  "preview-text-email"  ],
"  \["n", "gp",    "preview-html-email"  ],
"  \["n", "ga",    "download-attachments"],
"  \["n", "gn",    "new-email"           ],
