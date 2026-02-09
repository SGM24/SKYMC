import sys
PORT = 700
if len(sys.argv) > 1:
    PORT = int(sys.argv[1])
print(PORT)
import socket
IP = "0.0.0.0"
sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM) #IPv4, and UDP setup
sock.bind((IP,PORT))
sock.setblocking(False)

print("Listening for Godot frontend")

import json
import pydirectinput
pydirectinput.PAUSE = 0
pydirectinput.FAILSAFE = False
# MIDI Note : Scan Code (Hex)
key_map = {
    60: 'y',
    62: 'u',
    64: 'i',
    65: 'o',
    67: 'p',
    69: 'h',
    71: 'j',
    72: 'k',
    74: 'l',
    76: ';',
    77: 'n',
    79: 'm',
    81: ',',
    83: '.',
    84: '/'
}


while True:
    try:
        while True:
            data, addr = sock.recvfrom(1024) #buffer
            message = data.decode("utf-8")
            midi_list = json.loads(message)
            status = midi_list[0]
            note_number = midi_list[1]
            key = key_map.get(note_number)
            if key:
                if status == 144: #Note On
                    pydirectinput.keyDown(key)
                elif status == 128: # Note Off
                    pydirectinput.keyUp(key)
    except BlockingIOError:
        continue
    except Exception as e:
        pass