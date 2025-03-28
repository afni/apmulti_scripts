import socket
import numpy as np
import time

def sock_open_ctrl():
   # open socket at control port and say where we will send main data
   sockc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   sockc.connect(('localhost', 7961))
   dport = b'tcp:localhost:7960\0'
   sockc.sendall(dport)
   sockc.close()
   time.sleep(2)

def sock_open_tcp():
   # open socket at TCP port
   sockd = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
   sockd.connect(('localhost', 7960))
   time.sleep(2)
   return sockd

def get_epi_control_data():
   # send TCP data: EPI control info
   # (take out NUM_CHAN 3, just to be smaller)
   # dt0 = b'NUM_CHAN 3\nACQUISITION_TYPE 3D+timing\nZORDER seq\nTR 2.2\n'
   dctl = b'ACQUISITION_TYPE 3D+timing\nZORDER seq\nTR 2.2\n'    \
          b'XYFOV 204.998398 204.998398 115.500\n'               \
          b'XYMATRIX 2 3 4\nDATUM short\nXYZAXES R-L A-P I-S\n'  \
          b'BYTEORDER LSB_FIRST\n'                               \
          b'DRIVE_AFNI OPEN_WINDOW axialimage\n'                 \
          b'DRIVE_AFNI OPEN_WINDOW axialgraph\n'                 \
          b'\0'
   return dctl

def data_vol(nx, ny, nz, offset=0):
   adata = list([i+offset for i in range(nx*ny*nz)])
   return np.array(adata, dtype=np.int16)

# main
dctl = get_epi_control_data()
vdata = data_vol(2, 3, 4, 0)

sock_open_ctrl()
sockd = sock_open_tcp()
sockd.sendall(dctl)
time.sleep(2)

nt = 12
for ind in range(nt):
   sockd.sendall(data_vol(2,3,4,ind%4))
   time.sleep(0.5)
sockd.close()
