setlocal buftype=nofile
setlocal cursorline
setlocal nomodifiable
setlocal nowrap
setlocal startofline

nnoremap <silent> <plug>(ibis-prev-page-emails)     :call ibis#api#prev_page_emails()              <cr>
nnoremap <silent> <plug>(ibis-next-page-emails)     :call ibis#api#next_page_emails()              <cr>
nnoremap <silent> <plug>(ibis-first-page-emails)    :call ibis#api#first_page_emails()              <cr>
nnoremap <silent> <plug>(ibis-select-folder)        :call ibis#ui#select_folder()                  <cr>
nnoremap <silent> <plug>(ibis-select-profile)       :call ibis#ui#select_profile()                 <cr>
nnoremap <silent> <plug>(ibis-delete-profile)       :call ibis#ui#delete_profile()                 <cr>


call ibis#utils#define_maps([
  \["n", "gp",   "prev-page-emails"    ],
  \["n", "gn",   "next-page-emails"    ],
  \["n", "gb",   "first-page-emails"    ],
  \["n", "fs",   "select-folder"       ],
  \["n", "ps",   "select-profile"      ],
  \["n", "pd",   "delete-profile"      ],
\])

"  \["n", "<cr>", "preview-text-email"  ],
"  \["n", "gp",   "preview-html-email"  ],
"  \["n", "ga",   "download-attachments"],
"  \["n", "gn",   "new-email"           ],
