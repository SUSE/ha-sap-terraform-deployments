#!/usr/bin/env python

import base64
import errno
import httplib
import json
import socket
import sys
import time

def do(method, connection, headers, path, body=None):
    connection.request(method, path, headers=headers, body=json.dumps(body))
    resp = connection.getresponse()
    content = resp.read()

    if resp.status != 200:
        raise IOError("Unexpected HTTP status received on %s: %d" % (path, resp.status))

    return json.loads(content)


connection = httplib.HTTPConnection("localhost")

# try to connect, multiple times if ECONNREFUSED is raised
# (service is up but not ready for requests yet)
for retries in range(0,10):
    try:
        connection.connect()
    except socket.error as e:
        if e.errno != errno.ECONNREFUSED:
            raise e
        print("Connection refused, retrying...")
        time.sleep(1)

token = base64.b64encode("admin:admin".encode("ASCII")).decode("ascii")
headers = {
  "Authorization" : "Basic %s" %  token,
  "Content-Type" : "application/json; charset=utf8"
}

do("PUT", connection, headers, "/api/org/preferences", {"homeDashboardId" : 1})
