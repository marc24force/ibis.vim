if exists("b:current_syntax")
  finish
endif

syntax match ibis_mail          /[a-zA-Z\.\_\-]\+@[a-zA-Z\.\_\-]\+/
syntax match ibis_separator     /|/
syntax match ibis_table_date    /|\d\d\/\d\d\/\d\d, \d\dh\d\d |$/ contains=ibis_table_date,ibis_separator
syntax match ibis_table_flag    /^|.\{-}|/                        contains=ibis_table_flag,ibis_separator
syntax match ibis_table_mail    /^|.\{-}|.\{-}|/                  contains=ibis_mail,ibis_table_flag,ibis_table_mail,ibis_separator
syntax match ibis_table_subject /^|.\{-}|.\{-}|.*|.\{-}|$/        contains=ibis_mail,ibis_table_flag,ibis_table_mail,ibis_table_subject,ibis_separator,ibis_table_date
syntax match ibis_table_head    /.*\%1l/                          contains=ibis_separator
syntax match ibis_new_mail      /^|N.*|$/                         contains=ibis_table_flag,ibis_separator

highlight default link ibis_mail            Tag
highlight default link ibis_separator       VertSplit
highlight default link ibis_table_flag      Comment
highlight default link ibis_table_subject   String
highlight default link ibis_table_date      Structure

highlight ibis_table_head term=bold,underline cterm=bold,underline gui=bold,underline
highlight ibis_new_mail   term=bold           cterm=bold           gui=bold

let b:current_syntax = "ibis-list"
