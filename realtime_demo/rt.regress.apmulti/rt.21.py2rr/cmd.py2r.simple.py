#!/usr/bin/env python

# run this with no arguments to test communcation with realtime_receiver.py

import socket, time

host = 'localhost'
port = 53214

# ======================================================================
# babble
print("\n"                                                      \
      "-- Expecting realtime_receiver.py to be already running.\n" \
      "   If not pleaset start it and try this program again:\n"   \
      "      realtime_receiver.py -show_data yes -verb 3\n"
      "   (use ctrl-c to stop)\n")

print("-- trying to connect to rr.py at %s:%s ...\n" % (host, port))

# ======================================================================
# open a socket, send magic and nrois, then send data
sockd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    sockd.connect((host, port))
    print("++ SUCCESS\n")
except:
    print("** FAILURE to connect\n")

sockd.close()

