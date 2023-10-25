#!/usr/bin/env python3

import json
import logging
import os
import quopri
import re
import smtplib, ssl
import subprocess
import sys
import threading

from base64 import b64decode
from email import policy
from email.header import Header, decode_header
from email.mime.text import MIMEText
from email.parser import BytesParser, BytesHeaderParser
from email.utils import formataddr, formatdate, make_msgid
from imapclient.imapclient import IMAPClient

log_filename = os.path.join(os.path.dirname(os.path.realpath(__file__)), "ibis-api.log")
logging.basicConfig(filename=log_filename, format="[%(asctime)s] %(message)s", level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S")

imap_client = None
imap_host = imap_port = imap_login = imap_passwd = None
smtp_host = smtp_port = smtp_login = smtp_passwd = None

no_reply_pattern = r"^.*no[\-_ t]*reply"

def get_contacts():
    contacts = set()
    fetch = imap_client.fetch("1:*", ["ENVELOPE"])

    for [_, data] in fetch.items():
        envelope = data[b"ENVELOPE"]
        contacts = contacts.union(decode_contacts(envelope.to))

    return list(contacts)

def get_emails(last_seq, chunk_size):
    global imap_client

    emails = []
    if last_seq == 0:
        return emails

    ids = "%d:%d" % (last_seq, last_seq - chunk_size) if (last_seq > chunk_size) else "%d:%d" % (last_seq, 1)
    fetch = imap_client.fetch(ids, ["FLAGS", "ENVELOPE", "INTERNALDATE", "BODYSTRUCTURE"])

    for [uid, data] in fetch.items():
        envelope = data[b"ENVELOPE"]
        logging.info(data[b"BODYSTRUCTURE"])
        struct = data[b"BODYSTRUCTURE"][0] if isinstance(data[b"BODYSTRUCTURE"][0], list) else []
        has_attachment = "filename" in str(struct).lower()

        subject = decode_byte(envelope.subject)
        from_ = "" if envelope.from_ is None else envelope.from_[0]
        from_ = "" if from_ is "" else "@".join([decode_byte(from_.mailbox), decode_byte(from_.host)])
        to = "" if envelope.to is None else envelope.to[0]
        to = "" if to is "" else "@".join([decode_byte(to.mailbox), decode_byte(to.host)])
        date_ = data[b"INTERNALDATE"].strftime("%d/%m/%y, %Hh%M")

        email = dict()
        email["id"] = uid
        email["subject"] = subject
        email["from"] = from_
        email["to"] = to
        email["date"] = date_
        email["flags"] = get_flags_str(data[b"FLAGS"], has_attachment)
        email["message-id"] = envelope.message_id.decode()
        emails.insert(0, email)

    return emails

def get_email(id, format):
    global imap_client

    fetch = imap_client.fetch([id], ["BODY[]"])
    content = get_email_content(id, fetch.popitem()[1][b"BODY[]"])

    return content[format]

def get_flags_str(flags, has_attachment):
    flags_str = ""

    flags_str += "N" if not b"\\Seen" in flags else " "
    flags_str += "R" if b"\\Answered" in flags else " "
    flags_str += "F" if b"\\Flagged" in flags else " "
    flags_str += "D" if b"\\Draft" in flags else " "
    flags_str += "@" if has_attachment else " " 

    return flags_str
    
def download_attachments(dir, uid, data):
    attachments = []
    email = BytesParser(policy=policy.default).parsebytes(data)

    for part in email.walk():
        if part.is_attachment():
            attachment_name = part.get_filename()
            attachment = open(os.path.expanduser(os.path.join(dir, attachment_name)), "wb")
            attachment.write(part.get_payload(decode=True))
            attachment.close()
            attachments.append(attachment_name)

    return attachments

def get_email_content(uid, data):
    content = dict(text=None, html=None)
    email = BytesParser(policy=policy.default).parsebytes(data)

    for part in email.walk():
        if part.is_multipart():
            continue

        if part.get_content_type() == "text/plain":
            content["text"] = read_text(part)
            continue

        if part.get_content_type() == "text/html":
            content["html"] = read_html(part, uid)
            continue

    if content["html"] and not content["text"]:
        tmp = open(content["html"], "r")
        content["text"] = tmp.read()
        tmp.close()

    return content

def read_text(part):
    payload = part.get_payload(decode=True)
    return payload.decode(part.get_charset() or part.get_content_charset() or "utf-8")

def read_html(part, uid):
    payload = read_text(part)
    preview = write_preview(payload.encode(), uid)

    return preview

def write_preview(payload, uid, subtype="html"):
    preview = "/tmp/preview-%d.%s" % (uid, subtype)

    if not os.path.exists(preview):
        tmp = open(preview, "wb")
        tmp.write(payload)
        tmp.close()

    return preview

def decode_byte(byte):
    if byte is None:
        return ""

    decode_list = decode_header(byte.decode())

    def _decode_byte(byte_or_str, encoding):
        return byte_or_str.decode(encoding or "utf-8") if type(byte_or_str) is bytes else byte_or_str

    return "".join([_decode_byte(val, encoding) for val, encoding in decode_list])

def decode_contacts(contacts):
    return list(filter(None.__ne__, [decode_contact(c) for c in contacts or []]))

def decode_contact(contact):
    if not contact.mailbox or not contact.host: return None

    mailbox = decode_byte(contact.mailbox)
    if re.match(no_reply_pattern, mailbox): return None

    host = decode_byte(contact.host)
    if re.match(no_reply_pattern, host): return None

    return "@".join([mailbox, host]).lower()

class PreventLogout(threading.Thread):
    def __init__(self):
        self.event = threading.Event()
        super(PreventLogout, self).__init__()
        self.start()

    def run(self):
        global imap_client
        while not self.event.wait(60):
            logging.info("NOOP")
            imap_client.noop()

while True:
    request_raw = sys.stdin.readline()

    try: request = json.loads(request_raw.rstrip())
    except: continue

    logging.info("Receive: " + str({key: request[key] for key in request if key not in ["imap-passwd", "smtp-passwd"]}))

    if request["type"] == "login":
        try:
            imap_host = request["imap-host"]
            imap_port = request["imap-port"]
            imap_login = request["imap-login"]
            imap_passwd = request["imap-passwd"]

            smtp_host = request["smtp-host"]
            smtp_port = request["smtp-port"]
            smtp_login = request["smtp-login"]
            smtp_passwd = request["smtp-passwd"]

            imap_client = IMAPClient(host=imap_host, port=imap_port, ssl=True)
            imap_client.login(imap_login, imap_passwd)
            PreventLogout()

            folders = list(map(lambda folder: folder[2], imap_client.list_folders()))
            response = dict(success=True, type="login", folders=folders)
        except Exception as error:
            response = dict(success=False, type="login", error=str(error))

    elif request["type"] == "fetch-emails":
        try:
            emails = get_emails(request["seq"], request["chunk-size"])
            response = dict(success=True, type="fetch-emails", emails=emails)
        except Exception as error:
            response = dict(success=False, type="fetch-emails", error=str(error))

    elif request["type"] == "fetch-email":
        try:
            email = get_email(request["id"], request["format"])
            response = dict(success=True, type="fetch-email", email=email, format=request["format"])
        except Exception as error:
            response = dict(success=False, type="fetch-email", error=str(error))

    elif request["type"] == "download-attachments":
        try:
            fetch = imap_client.fetch([request["id"]], ["BODY[]"])
            attachments = download_attachments(request["dir"], request["id"], fetch.popitem()[1][b"BODY[]"])
            response = dict(success=True, type="download-attachments", attachments=attachments)
        except Exception as error:
            response = dict(success=False, type="download-attachments", error=str(error))

    elif request["type"] == "select-folder":
        try:
            folder = request["folder"]
            seq = imap_client.select_folder(folder)[b"UIDNEXT"]
            emails = get_emails(seq, request["chunk-size"])
            is_folder_selected = True
            response = dict(success=True, type="select-folder", folder=folder, seq=seq, emails=emails)
        except Exception as error:
            response = dict(success=False, type="select-folder", error=str(error))

    elif request["type"] == "send-email":
        try:
            message = MIMEText(request["message"])
            for key, val in request["headers"].items(): message[key] = val
            message["From"] = formataddr((request["from"]["name"], request["from"]["email"]))
            message["Message-Id"] = make_msgid()

            #smtp = smtplib.SMTP(host=smtp_host, port=smtp_port)
            #smtp.starttls()

            smtp = smtplib.SMTP_SSL(host=smtp_host, port=smtp_port)
            smtp.login(smtp_login, smtp_passwd)
            smtp.send_message(message)
            smtp.quit()

            imap_client.append("Sent", message.as_string())

            contacts_file = open(os.path.dirname(sys.argv[0]) + "/.contacts", "a")
            contacts_file.write(request["headers"]["To"] + "\n")
            contacts_file.close()

            response = dict(success=True, type="send-email")
        except Exception as error:
            response = dict(success=False, type="send-email", error=str(error))

    elif request["type"] == "extract-contacts":
        try:
            contacts = get_contacts()
            contacts_file = open(os.path.dirname(sys.argv[0]) + "/.contacts", "w+")
            for contact in contacts: contacts_file.write(contact + "\n")
            contacts_file.close()

            response = dict(success=True, type="extract-contacts")
        except Exception as error:
            response = dict(success=False, type="extract-contacts", error=str(error))

    json_response = json.dumps(response)
    logging.info("Send: " + str(json_response))
    sys.stdout.write(json_response + "\n")
    sys.stdout.flush()
