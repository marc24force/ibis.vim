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
logging.basicConfig(filename=log_filename, format="[%(asctime)s] %(message)s", level=logging.INFO, datefmt="%Y-%m-%d %H:%M:%S", filemode='w')

imap_client = None
imap_host = imap_port = imap_login = imap_pswd = None
smtp_host = smtp_port = smtp_login = smtp_pswd = None

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

    logging.info("Request: " + str({key: request[key] for key in request if key not in ["imap-pswd", "smtp-pswd"]}))

    if request["type"] == "nolog":
        logging.disable(logging.CRITICAL)
        response = dict(success=True, type="nolog")

    elif request["type"] == "login":
        try:
            imap_host = request["imap-host"]
            imap_port = request["imap-port"]
            imap_login = request["imap-login"]
            imap_pswd = request["imap-pswd"]

            smtp_host = request["smtp-host"]
            smtp_port = request["smtp-port"]
            smtp_login = request["smtp-login"]
            smtp_pswd = request["smtp-pswd"]

            imap_client = IMAPClient(host=imap_host, port=imap_port, ssl=True)
            imap_client.login(imap_login, imap_pswd)
            PreventLogout()

            folders = list(map(lambda folder: folder[2], imap_client.list_folders()))
            response = dict(success=True, type="login", folders=folders)
        except Exception as error:
            response = dict(success=False, type="login", error=str(error))

    json_response = json.dumps(response)
    logging.info("Response: " + str(json_response))
    sys.stdout.write(json_response + "\n")
    sys.stdout.flush()
