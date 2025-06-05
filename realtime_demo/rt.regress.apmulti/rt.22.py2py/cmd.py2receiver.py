#!/usr/bin/env python

# run this with no arguments to test communcation with realtime_receiver.py
# (or test with cmd.receiver.py or psychopy ...)

import socket, time, sys
import numpy as np

host = 'localhost'
port = 53214
nt   = 5            # number of time points of data to send

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

# for each time point, append current data and alter current data
for i in range(nt):
   dall.append(d)
   d = [1.1*v for v in d]
npdata = np.array(dall, dtype=np.float32)


# ======================================================================
# babble
print("\n"                                                       \
      "-- Expecting some receiver to already be running.\n"      \
      "   If not pleaset start it and try this program again:\n" \
      "      python cmd.receiver.py\n"                           \
      "   (use ctrl-c to stop)\n")

print("-- trying to connect to rr.py at %s:%s ..." % (host, port))
print("   (and send %d time points of data)\n" % nt)


# ======================================================================
# open a socket, send magic and nrois, then send data
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

# send nt time points of motion and extras
try:
    print("-- send data ...")
    for d in npdata:
        sockd.sendall(d)
        time.sleep(0.5)
except:
    print("** FAILURE to send data")
    print("   - this is okay and expected with cmd.receiver.py,")
    print("     which closes ports after receiving magic and nROIs\n")
    sockd.close()
    sys.exit(1)

print("++ SUCCESS\n")

# and close
sockd.close()

