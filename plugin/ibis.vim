" VARIABLES
let g:ibis_profile_path       = get(g:, "ibis_profile_path", "$HOME/.config/ibis")
let g:ibis_profile_default    = get(g:, "ibis_profile_default", "")

let g:ibis_profile_encrypted  = get(g:, "ibis_profile_encrypted", 0)
let g:ibis_profile_enc_func   = get(g:, "ibis_profile_enc_func", "openssl enc -aes-256-cbc -k %s -base64 -A -pbkdf2")
let g:ibis_profile_dec_func   = get(g:, "ibis_profile_dec_func", "openssl enc -d -aes-256-cbc -k %s -base64 -A -pbkdf2")

let g:ibis_json_format_tool   = get(g:, "ibis_json_format_tool", "python -m json.tool %s > %s_tmp && mv %s_tmp %s")











" COMMANDS
command! Ibis call ibis#loop()
