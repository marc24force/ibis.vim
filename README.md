⚠ *This project is still in development is not yet ready for use*

# 𓅞 Ibis.vim

Simple mail client for Vim, this work is based on [Iris.vim](https://github.com/soywod/iris.vim) 

[//]: #( TODO: Update image)
[//]: #![image](https://user-images.githubusercontent.com/10437171/84173056-07664c00-aa7d-11ea-919f-a973120a8439.png)

## Table of contents

  - [Motivation](#motivation)
    - [From Iris to Ibis](#Iris)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Configuration](#configuration)
    - [Identity](#identity-required)
    - [IMAP](#imap-required)
    - [SMTP](#identity-required)
    - [Passwords](#passwords)
    - [Idle mode](#idle-mode)
    - [Pagination](#pagination)
    - [Attachments](#attachments)
  - [Usage](#usage)
    - [Email list](#list-mails)
    - [Email text preview](#email-text-preview)
    - [Email composition](#email-composition)
    - [Folders](#folders)
    - [Flags](#flags)
    - [Contacts](#contacts)
  - [Changelog](https://github.com/soywod/iris.vim/blob/master/CHANGELOG.md)
  - [Contributing](#contributing)

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

New changes made are shown in the [changelog](CHANGELOG.md). However the main
differences with Iris are:
  - Support for SSL connection
  - Improved key mapping

## Requirements

  - Python3 support enabled `:echo has("python3")`
  - Job enabled `:echo has("job")`
  - Channel enabled `:echo has("channel")`

This project will be only tested on Vim8+, if you want to use it on Neovim
I can't guarantee full functionality.

## Installation

For eg. with [`vim-plug`](https://github.com/junegunn/vim-plug):

```vim
Plug "marc24force/ibis.vim"
```

## Configuration

Before using Ibis, you need to configure it:

### Identity (required)

```vim
let g:ibis_name  = "My name"
let g:ibis_mail = "your@mail.com"
```

### IMAP (required)

```vim
let g:ibis_imap_host  = "your.imap.host"
let g:ibis_imap_port  = 993
let g:ibis_imap_login = "Your IMAP login" "Default to g:ibis_mail
```

### SMTP (required)

```vim
let g:ibis_smtp_host  = "your.smtp.host" "Default to g:ibis_imap_host
let g:ibis_smtp_port  = 587
let g:ibis_smtp_login = "Your IMAP login" "Default to g:ibis_mail
```

### Passwords

On startup, Ibis always asks for your IMAP and SMTP passwords. To avoid this,
you can save your password in a file and encrypt it via
[GPG](https://gnupg.org/):

```bash
gpg --encrypt --sign --armor --output myfile.gpg myfile
```

```vim
let g:ibis_imap_passwd_filepath = "/path/to/imap.gpg"
let g:ibis_smtp_passwd_filepath = "/path/to/smtp.gpg"
```

Note: `ibis_imap_passwd_filepath` & `ibis_smtp_password_filepath` must be absolute paths.  For example the path `~/passwords/imap.gpg` would not work because of the `~`.

If you want to use something else than GPG, you can set up your custom command.
For eg., with the MacOSX `security` tool:

```vim
let g:ibis_imap_passwd_show_cmd = "security find-internet-password -gs IMAP_KEY -w"
let g:ibis_smtp_passwd_show_cmd = "security find-internet-password -gs SMTP_KEY -w"
```

### Idle mode

On startup, Ibis spawns two Python jobs: one for the API, one for the [idle
mode](https://imapclient.readthedocs.io/en/2.1.0/advanced.html#watching-a-mailbox-using-idle).
The last one allows you to receive notifications on new mails. You can disable
this option or change the default timeout (every 15s):

```vim
let g:ibis_idle_enabled = 1
let g:ibis_idle_timeout = 15
```

### Pagination

By default, Ibis fetches your last 50 mails:

```vim
let g:ibis_emails_chunk_size = 50
```

*Note: the pagination is based on message sequences which is not necessary
consecutive. It makes the pagination less accurate (doesn't fetch always the
same amount of mails) but more performant.*

### Attachments

```vim
let g:ibis_download_dir = "~/Downloads"
```

## Usage

### Email list

```vim
:Ibis
```

Function | Default keybind | Override
--- | --- | ---
Preview (text) | `<Enter>` | `nmap <cr> <plug>(ibis-preview-text-email)`
Preview (html) | `gp` (for `go preview`) | `nmap gp <plug>(ibis-preview-html-email)`
Download attachments | `ga` (for `go attachments`) | `nmap ga <plug>(ibis-download-attachments)`
New mail | `gn` (for `go new`) | `nmap gn <plug>(ibis-new-email)`
Previous page | `<Ctrl+b>` (for `page backward`) | `nmap <c-b> <plug>(ibis-prev-page-emails)`
Next page | `<Ctrl+f>` (for `page forward`) | `nmap <c-f> <plug>(ibis-next-page-emails)`
Change folder | `gf` (for `go folder`) | `nmap gf <plug>(ibis-change-folder)`

### Email text preview

Function | Default keybind | Override
--- | --- | ---
Reply | `gr` (for `go reply`) | `nmap gr <plug>(ibis-reply-email)`
Reply all | `gR` (for `go reply all`) | `nmap gR <plug>(ibis-reply-all-email)`
Forward | `gf` (for `go forward`) | `nmap gf <plug>(ibis-forward-email)`

### Email composition

Ibis is based on the builtin `mail.vim` filetype and syntax. An email should
contains a list of headers followed by the message:

```vim
To: mail@test.com
Subject: Welcome

Hello world!
```

Function | Default keybind | Override
--- | --- | ---
Save draft | `:w` |
Send | `gs` (for `go send`) | `nmap gs <plug>(ibis-send-email)`

### Folders

By default, Ibis will display a basic prompt to select your folders:

```vim
:IbisFolder
```

Ibis supports those fuzzy finders:

  - [fzf](https://github.com/junegunn/fzf) ([fzf.vim](https://github.com/junegunn/fzf.vim) need to be installed as well)

*Note: Ibis will use the first fuzzy finder available automatically.*

### Flags

Flags appears in the first column of the [email list](#email-list) view. There
is 5 different flags:

  - `N` if it's a new email
  - `R` if it has been replied
  - `F` if it has been flagged
  - `D` if it's a draft
  - `@` if it contains an attachment

### Contacts

In order to autocomplete addresses, Ibis keeps a `.contacts` file that contains
emails of your contacts. It's updated each time you send a new email (only the
`To` header is used). You can extract existing addresses from all your emails:

```vim
:IbisExtractContacts
```

*Note: the completion may need to be triggered manually via `<C-x><C-u>`, see
`:h i_CTRL-X_CTRL-U`.*

## Contributing

Git commits must start with:
  - `[NEW]:` When adding a new feature
  - `[UPD]:` When updating a feature or improving it
  - `[FIX]:` When fixing an issue
  - `[DEL]:` When removing a feature

  > Don't need to mention the action done after the braked prefix, just the
  > feature or files affected. In case of removing the reason must be stated
  > First letter after the prefix must be capital, and no dot (.) at the end.

Code should be as clean as possible, variables and functions use the snake case
convention. A line should never contain more than `80` characters.

Tests should be added for each new functionality. Be sure to run tests before
proposing a pull request.

## Credits

  - [Iris](https://github.com/soywod/iris.vim)
  - [Neomutt](https://neomutt.org/)
  - [Alpine](http://alpine.x10host.com/alpine/alpine-info/)
  - [IMAPClient](https://github.com/mjs/imapclient)
    - Class [IMAPClient](https://github.com/mjs/imapclient/blob/580dc6781b5bf9d4f2a1a74b5d4168ef9b842b87/imapclient/imapclient.py#L162)
    - [Example](https://github.com/mjs/imapclient/blob/master/examples/example.py)
    - [Idle example](https://github.com/mjs/imapclient/blob/master/examples/idle_example.py)
  - IMAP [RFC3501](https://tools.ietf.org/html/rfc3501)
    - [Flags](https://tools.ietf.org/html/rfc3501#section-2.3.2)
    - [Status](https://tools.ietf.org/html/rfc3501#section-6.3.10)
    - [Search](https://tools.ietf.org/html/rfc3501#section-6.4.4)
    - [Fetch](https://tools.ietf.org/html/rfc3501#section-7.4.2)
