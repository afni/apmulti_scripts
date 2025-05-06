#!/usr/bin/env python

# run this with no arguments to test communcation with realtime_receiver.py

import socket, time
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
print("\n"                                                      \
      "-- Expecting realtime_receiver.py to be already running.\n" \
      "   If not pleaset start it and try this program again:\n"   \
      "      realtime_receiver.py -show_data yes -verb 3\n"
      "   (use ctrl-c to stop)\n")

print("-- trying to connect to rr.py at %s:%s ..." % (host, port))
print("   (and send %d time points of data)\n" % nt)


# ======================================================================
# open a socket, send magic and nrois, then send data
sockd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    sockd.connect((host, port))
    time.sleep(1)
    sockd.sendall(npmagic)
    sockd.sendall(nprois)

    # send nt time points of motion and extras
    for d in npdata:
        sockd.sendall(d)
        time.sleep(0.5)

    print("++ SUCCESS\n")
except:
    print("** FAILURE to connect to remote host at %s:%s\n" % (host, port))

# and close
sockd.close()

