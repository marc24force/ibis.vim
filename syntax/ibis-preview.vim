if exists("b:current_syntax") | finish | endif

syntax match ibis_info_thread   /^>.*$/

highlight default link ibis_info_thread   Comment

let b:current_syntax = "ibis-preview"
