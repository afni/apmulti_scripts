#!/usr/bin/env python

# run this with no arguments to test communcation with realtime_receiver.py
# (or test with cmd.receiver.py or psychopy ...)

import socket, time, sys
import numpy as np

host = 'localhost'
port = 53214

# ======================================================================
# data to send: magic, nROIs, and a per-TR list of 6+nROIs values

# magic : magic string for motion plus ROI averages, send 2 ROI averages
magic   = [0xab, 0xcd, 0xef, 0xac]
nrois   = [2]

# and put into binary arrays
npmagic = np.array(magic, dtype=np.uint8)
nprois  = np.array(nrois, dtype=np.int32)

# ----------
# create 2D list of time points of data
dall = []
d = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 10, 20]  # basic motion and ROI data


# ======================================================================
# babble
print("\n"                                                       \
      "-- Expecting some receiver to already be running.\n"      \
      "   If not pleaset start it and try this program again:\n" \
      "      python cmd.receiver.py\n"                           \
      "   (use ctrl-c to stop)\n")

print("-- trying to connect to rr.py at %s:%s ...\n" % (host, port))


# ======================================================================
# open a socket, send magic and nrois
sockd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    print("-- connect() and send magic ...")
    sockd.connect((host, port))
    time.sleep(1)
    sockd.sendall(npmagic)
except:
    print("** FAILURE to connect to remote host at %s:%s\n" % (host, port))
    sockd.close()
    sys.exit(1)

try:
    print("-- send nROIs ...")
    sockd.sendall(nprois)
except:
    print("** FAILURE to send nROIs")
    sockd.close()
    sys.exit(1)


# no other data (motion, ROI aves) is sent for this test


print("++ SUCCESS\n")

# and close
sockd.close()

