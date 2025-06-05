#!/usr/bin/env python

# the basic guts of realtime_receiver.py
# checking for success at each stage
# (but not looking for actual motion params or ROI averages)

import sys, socket

try:
    server_port = 53214
    print("-- socket(),bind(),listen() at port %s ..." % server_port)
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.bind(('', server_port))
    server_sock.settimeout(None)
    server_sock.listen(2)
    print("++ success: have opened socket")
except:
    print("** failed to bind() and listen()")
    sys.exit(1)

try:
    print("-- accepting connections ...")
    data_sock, data_address = server_sock.accept()
    print("++ success: are accepting connections")
except:
    print("** failed to accept() a connection")
    sys.exit(1)

try:
    print("-- waiting to recv() magic string ...")
    flag=socket.MSG_WAITALL
    nbytes = 4
    data = data_sock.recv(nbytes, flag)
    print("++ success: received data (magic string): %s" % data)
except:
    print("** failed to recv() %d bytes of data" % nbytes)
    sys.exit(1)

try:
    print("-- waiting to recv() nROIs ...")
    flag=socket.MSG_WAITALL
    nbytes = 4
    data = data_sock.recv(nbytes, flag)
    print("++ success: received data (nROIs): %s" % data)
except:
    print("** failed to recv() %d bytes of data" % nbytes)
    sys.exit(1)

print("-- closing up shop, not waiting for actual data")

data_sock.close()
server_sock.close()

print("== SUCCESS\n")

