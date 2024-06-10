# 𓅞 Ibis.vim

Simple mail client for Vim, this work is based on [Iris.vim](https://github.com/soywod/iris.vim) 

## Motivation

I always wanted to have a integrated mail client in Vim. For me using a client
with Vim-like commands was not enough, I wanted to use my plugins and mappings.
Then I found *Iris*:

(Neo)Mutt and Alpine are very good terminal mail clients, but they lack of Vim
mappings. You can emulate, but it requires a lot of time, patience and
configuration. Why trying to emulate, when you can have it in Vim? VimL and
Python are strong enough to do so. The aim of Iris is to provide a simple mail
client that:

  - Allows you to manage your mails inside Vim
  - Does not slow down neither Vim nor your workflow (async+lazy)
  - Is built on the top of a robust [Python IMAP client](https://github.com/mjs/imapclient) to avoid implementing IMAP protocol logic

### From Iris to Ibis

Unfortunately when I found Iris the project was already archived. Instead it was
succeeded by [himalaya](https://github.com/soywod/himalaya) a more robust mail
client with support for a Vim plugin.

Yet it didn't work for me. Therefore, as we say in Catalan "Si vols estar ben
servit, fes-te tu mateix el llit", which roughly translates to: Do it yourself.

Since I was already working on a personal project named Iris I decided to rename
this fork. Iris made me think on Osiris, then Isis and then Thoth, Egyptian god
of messages. Well, Thoth is supposed to be an ibis, so you can guess where the
new name came to be. 𓁟 

New changes made are shown in the [changelog](CHANGELOG.md).
In 2024 the project was redone from scratch in order to fix some issues and wrap up some in-progress features.

## Requirements

  - Python3 support enabled `:echo has("python3")`
  - Job enabled `:echo has("job")`
  - Channel enabled `:echo has("channel")`
  - Install python library imapclient
  - Install google auth2 libraries
>```bash
>pip install imapclient google-auth google-auth-oauthlib
>```

This project will be only tested on Vim8+, if you want to use it on Neovim
I can't guarantee full functionality.

## Installation

For eg. with [`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug "marc24force/ibis.vim"
```

## Configuration
Unlike it's predecessor, in Ibis you don't need to configure a file with Vim global variables to set up your e-mail. 
Instead Ibis manages multiple profiles which you can use for different mail accounts.
By default the profile file is stored in `$HOME/.config/ibis/`.
This can be modified by adding to your `vimrc`:

```vim
let g:ibis_profile_path = "/path/to/dir/"
```

On startup, if the profile file can't be found, it will start a profile editor buffer so you can set up your mail.

If you have multiple profiles, the first one will be loaded. 
In case you want to specify a default profile this can be set with:

```vim
let g:ibis_profile_default = "Profile"
```

`profile` is a json file, therefore it can also be edited directly instead of using Ibis editor, however, see the next section for encryption.
If the file is not encrypted it will be formated to be readable using python, this setting can be changed if you prefer to use a different tool.
Note that you have to use `%s` as a placeholder for the profile file.

```vim
let g:ibis_json_format_tool = "python -m json.tool %s > %s_tmp && mv %s_tmp %s"
```

## Passwords
When setting up a profile you can decide to leave the IMAP and SMTP password blank.
In that case you will be asked to provide those at login.

If you prefer to have the passwords saved you can encrypt the profile file for more security.

```vim
let g:ibis_profile_encrypted = 1
```

By default the encryption uses OpenSSL, if you prefer to use a different approach you can modify the following variables.
Note that you have to use `%s` as a placeholder for the key, which you will be asked to input once for each session.

```vim
let g:ibis_profile_enc_func = "openssl enc -aes-256-cbc -k %s -base64 -A -pbkdf2"
let g:ibis_profile_dec_func = "openssl enc -d -aes-256-cbc -k %s -base64 -A -pbkdf2"
```

Ibis provides a logging feature to help identify any issue when sending and receiving data.
The passwords are always hidden from the log, however, in case that you want to avoid having sensible information stored you can disable it with:

```vim
let g:ibis_logging = 0
```

## TODO

General:
- ✓ OAUTH2 support
- ✗ Encrypt OAUTH2 files
- ✗ Multilanguage

In Ibis list:
- ✓ `fs` (folder select: allows to change the current selected folder)
- ✓ `ps` (profile select: allows to change the current profile, it also allows to create a new one)
- ✓ `pd` (profile delete: deletes an existing profile)
- ✗ `pe` (profile edit: modifies an existing profile)
- ✓ `u`  (update: updates the list of mails to check for new mails)
- ✗ `<cr>` (enter: open the mail under the cursor)
- ✗ `mh` (mail html: open the mail under the cursor in an html viewer)
- ✗ `mw` (mail new: Write a new mail)
- ✗ `ma` (mail attachment: download attachments of the mail under the cursor)
- ✗ `mr` (mail reply: reply to the mail under the cursor)
- ✗ `mf` (mail forward: forward the mail under the cursor)
- ✓ `gn` (go next page: go to the next page)
- ✓ `gp` (go previous page: go to the previous page)
- ✓ `gb` (go back page: go to the first page)

In Ibis preview:
- ✗ `mh` (mail html: open the mail in an html viewer)
- ✗ `ma` (mail attachment: download attachments of the oppened mail)
- ✗ `mr` (mail reply: reply to the oppened mail)
- ✗ `mf` (mail forward: forward the oppened mail)
 
In Ibis compose:
- ✗ `ma` (mail attach: attach a file in the mail)
- ✗ `ms` (mail send: send the mail)
