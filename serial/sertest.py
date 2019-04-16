import serial
download_program = b''
memory_size = 2 ** 16

def openDownloadFile(download_file):
    try:
        with open(download_file, 'rb') as f:
            file_content = bytearray(f.read())
        file_content_list = []
        for b in file_content:
            file_content_list.append(b)
        global download_program
        file_content_list = [int(p) for p in file_content_list]
        download_program = bytes(file_content_list)
    except Exception:
        print("Error")
    return

download_file = "C:/Users/hansj/Dropbox/DTU/6. semester/Bachelorprojekt/Source files/tests/s_tests/test_add.bin"
openDownloadFile(download_file)
for i in range(0, len(download_program)-1):
    print(hex(download_program[i]))
ser = serial.Serial(port='COM4', baudrate=115200,
                    bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
ser.reset_input_buffer()
ser.reset_output_buffer()
ser.write(b'w')
i = 0
while i < memory_size:
    if i < len(download_program):
        ser.write(download_program[i:i+4])
        i += 4
    else:
        ser.write(b'\x00')
        i += 1
    download_progress = int(100 *(i / memory_size))
#upload_file = "C:/Users/hansj/Dropbox/DTU/6. semester/Bachelorprojekt/Source files/tests/s_tests/test_add.txt"
#saveUploadFile(upload_file)