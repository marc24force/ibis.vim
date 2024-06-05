" VARIABLES
let g:ibis_profile_path       = get(g:, "ibis_profile_path", "$HOME/.config/ibis")
let g:ibis_profile_default    = get(g:, "ibis_profile_default", "")
let g:ibis_oauth2_cred_path   = get(g:, "ibis_oauth2_cred_path", "$HOME/.config/ibis/oauth2")
let g:ibis_oauth2_tokens_path = get(g:, "ibis_oauth2_tokens_path", "$HOME/.config/ibis/oauth2/tokens")

let g:ibis_logging            = get(g:, "ibis_logging", 1)
let g:ibis_debug_print        = get(g:, "ibis_debug_print", 0)
let g:ibis_profile_encrypted  = get(g:, "ibis_profile_encrypted", 0)
let g:ibis_profile_enc_func   = get(g:, "ibis_profile_enc_func", "openssl enc -aes-256-cbc -k %s -base64 -A -pbkdf2")
let g:ibis_profile_dec_func   = get(g:, "ibis_profile_dec_func", "openssl enc -d -aes-256-cbc -k %s -base64 -A -pbkdf2")

let g:ibis_json_format_tool   = get(g:, "ibis_json_format_tool", "python -m json.tool %s > %s_tmp && mv %s_tmp %s")

let g:ibis_emails_chunk_size  = get(g:, "ibis_emails_chunk_size", 50)




" COMMANDS
command! Ibis call ibis#loop()
