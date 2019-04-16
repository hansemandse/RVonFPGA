# *******************************************************************************************
#              |
# Title        : Implementation and Optimization of a RISC-V Processor on a FPGA
#              |
# Developers   : Hans Jakob Damsgaard, Technical University of Denmark
#              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#              |
# Purpose      : This file is a part of a full system implemented as part of a bachelor's
#              : thesis at DTU. The thesis is written in cooperation with the Institute
#              : of Mathematics and Computer Science.
#              : This program allows download of test programs to the FPGA from a PC via
#              : a UART connection. The original program was developed by Luca Pezzarossa
#              : for the course 02203 at DTU, see https://github.com/lucapezza/02203-serial-interface 
#              |
# Revision     : 1.0   (last updated March 28, 2019)
#              |
# Available at : https://github.com/hansemandse/RVonFPGA
#              |
# *******************************************************************************************

from appJar import gui
import sys
import glob
import serial
import re
from PIL import Image, ImageTk
import tkinter as tk
import time
import threading

################################################################################
# Configuration constants
runChar = b'R'
testChar = b't'
testCharAns = b'y'
downloadChar = b'w'
uploadChar = b'r'
clearChar = b'c'

################################################################################
# Variables
download_program = b''
upload_memcontent = b''

memory_size = 2 ** 16

download_progress = 0
upload_progress = 0

fig_d_app = None
fig_u_app = None
help_app = None

current_port = ""

serial_available = False  # If false, the list of serials is empty
serial_free = True
program_downloaded = False

################################################################################
help_text = """Serial interface help
-Purpose
This application allows the download of test programs to the
FPGA as well as upload of register file content from the FPGA.
-Usage
The application is divided into 3 sections: 1) Setup serial
connection to the FPGA board, 2) Download test program to the
FPGA board, and 3) Upload register file content from the FPGA 
board. The functionality of these three sections is explained
in the following.
1) Setup serial connection to the FPGA board:
In this section you can setup the connection to the FPGA
board. The FPGA board needs to be connected and the FPGA
needs to be configured in order for the application be
able to interact with the serial port.
All the serial ports are listed in the drop-menu at the
top of this section. By pressing the button 'Refresh list'
you can update the entries of the list in case you connect
new devices.
Once you have selected the serial port of your board you
can test if the FPGA board is connected to the selected
serial port by pressing the button 'Test port'.
By pressing the button 'Clear entire memory content' you
can clear the entire FPGA board memory content (reset all
entries to 0).
2) Download image to the FPGA board:
In this section you can download a test program binary file
to the FPGA by pressing the button 'Download'.
3) Upload image from the FPGA board:
In this section you can upload register file content from
the FPGA by pressing the button 'Upload'.
"""

about_text = """Original application developed by Luca 
Pezzarossa, lpez@dtu.dk, for the course 02203 - Design 
of Digital Systems at the Technical University of Denmark.
This version was edited by Hans Jakob Damsgaard,
s163915@student.dtu.dk, for a bachelor's project under
approval by Luca Pezzarossa.
Version 1.1 - 2019
To report bugs, contact: s163915@student.dtu.dk
Copyright 2017 Luca Pezzarossa under the Apache License,
Version 2.0 (see help for details).
Copyright 2019 Hans Jakob Damsgaard under the MIT License.
The GUI was developed using appJar."""

################################################################################
# This function returns the list of all available serial ports.
def serial_ports():
    global serial_available
    global serial_free
    serial_free = False
    #global serial_available
    """ Lists serial port names
        :raises EnvironmentError:
            On unsupported or unknown platforms
        :returns:
            A list of the serial ports available on the system
    """
    if sys.platform.startswith('win'):
        ports = ['COM%s' % (i + 1) for i in range(256)]
    elif sys.platform.startswith('linux') or sys.platform.startswith('cygwin'):
        # this excludes your current terminal "/dev/tty"
        ports = glob.glob('/dev/tty[A-Za-z]*')
    elif sys.platform.startswith('darwin'):
        ports = glob.glob('/dev/tty.*')
    else:
        app.errorBox("Error!", "Unsupported or unknown platform.")
        result = ["-No serial ports available-"]
        serial_available = False
        serial_free = True
        return result

    result = []
    for port in ports:
        try:
            s = serial.Serial(port)
            s.close()
            result.append(port)
        except (OSError, serial.SerialException):
            pass
    if len(result) == 0:
        result = ["-No serial ports available-"]
        serial_available = False
    else:
        serial_available = True
    serial_free = True
    return result

def resetDownload(button):
    global download_program
    global download_progress
    download_program = b'0'
    download_progress = 0
    app.setEntry(
        "entry_d1", 
        "Select test to download.",
        callFunction=False
    )
    return

def resetUpload(button):
    global upload_memcontent
    global upload_progress
    upload_memcontent = b'0'
    upload_progress = 0
    app.setEntry(
        "entry_u1", 
        "Select where to save the uploaded memory content.", 
        callFunction=False
    )
    return

def openDownloadFile(button):
    # Retrieve name of download file from the entry in the app
    download_file = app.openBox(title="Open binary file", dirName=None, fileTypes=[
                                ('binary', '*.bin')], asFile=False)

    # If the download file name is not empty, read the file and check for correctness
    if download_file != "":
        try:
            # Open the file in read mode
            with open(download_file, 'rb') as f:
                # Read all bytes from the file
                file_content = bytearray(f.read())
            # with open automatically closes the file when finished
            file_content_list = []
            for b in file_content:
                file_content_list.append(b)
        except Exception:
            app.errorBox("Error!", "The selected file cannot be opened.")
            return

        # Check that the test program is not too large for the instruction memory
        if len(file_content_list) > memory_size:
            app.errorBox("Error!", "The selected test program is too large for the memory.")
            return

        global download_program
        download_program = bytes(file_content_list)

        # The test program has not been downloaded
        global program_downloaded
        program_downloaded = False

        # Insert the file name in the entry box in the app
        app.setEntry(
            "entry_d1", 
            download_file, 
            callFunction=False
        )
        return
    else:
        return

def saveUploadFile(button):
    global upload_memcontent
    upload_file = app.saveBox(title="Save binary file", dirName=None, fileName="upload.bin",
                              fileExt=".bin", fileTypes=[('binary', '*.bin')], asFile=False)
    if upload_file != "":
        try:
            memcontent_tmp = bytearray(upload_memcontent)
            with open(upload_file, "w+b") as f:
                f.write(memcontent_tmp)
        except Exception as e:
            app.errorBox("Error!", "The selected file cannot be opened.")
            return
        app.setEntry("entry_u1", upload_file, callFunction=False)
        return
    else:
        return

def showHelp():
    global help_app
    if help_app is not None:
        help_app.destroy()
        help_app = None
    help_app = tk.Toplevel()  # tk.Tk()#gui("Show figure")#S, "500x500")
    help_app.title("Serial interface help")
    help_app.resizable(False, False)
    S = tk.Scrollbar(help_app)
    T = tk.Text(help_app, height=25, width=60)
    S.pack(side=tk.RIGHT, fill=tk.Y)
    T.pack(side=tk.LEFT, fill=tk.Y)
    S.config(command=T.yview)
    T.config(yscrollcommand=S.set)
    T.insert(tk.END, help_text)
    T.configure(state="disabled")
    help_app.mainloop()
    return

def bottom_press(button):
    if button == "Help":
        showHelp()
        return
    if button == "About":
        app.infoBox("About", about_text)
        return
    if button == "Exit":
        app.stop()
        return
    return

def refreshSerialListTh():
    global serial_free
    serial_free = False
    app.changeOptionBox("list_serial_s", ["-Refreshing list...-"])
    serial_ids = serial_ports()
    app.changeOptionBox("list_serial_s", serial_ids)
    app.setEntry(
        "entry_s1", 
        "Test if the FPGA board is connected to this serial port.", 
        callFunction=False)
    serial_free = True
    return

def refreshSerialList(button):
    serTh = threading.Thread(target=refreshSerialListTh)
    serTh.daemon = True
    serTh.start()
    return

def downloadSerialTh():
    global download_progress
    global download_program
    download_progress = 0
    global program_downloaded
    global serial_free
    # Mark the serial connection as being in use
    serial_free = False
    # time.sleep(10)
    try:
        if not(serial_available):
            app.errorBox("Error!", "No serial ports available.")
        else:
            # Check that the serial connection is indeed available
            testSerial_cnt = 10
            while(not(testSerial())):
                testSerial_cnt = testSerial_cnt - 1
                if testSerial_cnt == 0:
                    break
                time.sleep(0.1)
            # If the connection is available, start the download of the test program
            if testSerial():
                # Create and open a serial connection
                ser = serial.Serial(port=app.getOptionBox("list_serial_s"), baudrate=115200,
                                    bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
                ser.reset_input_buffer()
                ser.reset_output_buffer()
                # Bring controller into its download state
                ser.write(downloadChar)
                # Upload the entire test program - one instruction at a time
                # followed by a lot of zero-bytes
                i = 0
                while i < memory_size:
                    if i < len(download_program):
                        ser.write(download_program[i:i+4])
                        i += 4
                    else:
                        ser.write(b'\x00')
                        i += 1
                    download_progress = int(100 *(i / memory_size))
                # Close the serial connection after finishing the download
                ser.close()
                download_progress = 100
                program_downloaded = True
            else:
                app.errorBox(
                    "Error!", "Impossible to communicate with the FPGA board on the selected serial port.")
    except:
        app.errorBox(
            "Error!", "Impossible to communicate on the selected serial port.")
    # Mark the serial connection as being free again
    serial_free = True
    return

def clearMemoryTh():
    global download_progress
    global serial_free
    # Mark the serial connection as being in use
    serial_free = False
    try:
        if not(serial_available):
            app.errorBox("Error!", "No serial ports available.")
        else:
            # Check that the serial connection is indeed available
            testSerial_cnt = 10
            while(not(testSerial())):
                testSerial_cnt = testSerial_cnt - 1
                if testSerial_cnt == 0:
                    break
                time.sleep(0.1)
            # If the connection is available, write the clear character
            if testSerial():
                # Create and open a serial connection
                ser = serial.Serial(port=app.getOptionBox("list_serial_s"), baudrate=115200,
                                    bytesize=8, parity='N', stopbits=1, timeout=None, xonxoff=0, rtscts=0)
                ser.reset_input_buffer()
                ser.reset_output_buffer()
                # Bring the controller into its clear state
                ser.write(clearChar)
                time.sleep(1)
                # Close the serial connection after finishing the communication
                ser.close()
                # Reset the indicator that the program is downloaded
                download_progress = 0
            else:
                app.errorBox(
                    "Error!", "Impossible to communicate with the FPGA board on the selected serial port.")
    except:
        app.errorBox(
            "Error!", "Impossible to communicate on the selected serial port.")
    # Mark the serial connection as being free again
    serial_free = True
    return

def uploadSerialTh():
    global upload_progress
    global upload_memcontent
    upload_progress = 0
    global serial_free
    # Mark the serial connection as being in use
    serial_free = False
    try:
        if not serial_available:
            app.errorBox("Error!", "No serial ports available.")
        else:
            # Check that the serial connection is indeed available
            testSerial_cnt = 10
            while(not(testSerial())):
                testSerial_cnt = testSerial_cnt - 1
                if testSerial_cnt == 0:
                    break
                time.sleep(0.1)
            # If the serial connection is available, start the upload of the register file content
            if testSerial():
                # Create and open a serial connection
                ser = serial.Serial(port=app.getOptionBox("list_serial_s"), baudrate=115200,
                                    bytesize=8, parity='N', stopbits=1, timeout=1, xonxoff=0, rtscts=0)
                ser.reset_input_buffer()
                ser.reset_output_buffer()
                # Bring the controller into its upload state
                ser.write(uploadChar)
                # Attempt to read the first eight bytes
                upload_memcontent_size = 0
                read_data = ser.read(8)
                upload_memcontent_tmp = bytearray(b'')
                if len(read_data) == 0:
                    # Serial connection timed out (no data received within time)
                    app.errorBox(
                        "Error!", "No data was received on the selected serial port.")
                else:
                    # While there is still more data to receive, read in data and store it
                    while (len(read_data) != 0 and upload_memcontent_size < memory_size):
                        upload_memcontent_tmp.extend(read_data)
                        upload_memcontent_size = upload_memcontent_size + len(read_data)
                        upload_progress = int(100 * (upload_memcontent_size / memory_size))
                        read_data = ser.read(8)
                    # Update the indicator that the register file content is uploaded
                    upload_progress = 100
                    # Run checks on the received data to check its dimensions against the expected
                    if upload_memcontent_size < memory_size:
                        app.errorBox(
                            "Error!", "Not enough data was received on the selected serial port.")
                        upload_memcontent = bytes(b'0')
                    elif upload_memcontent_size > memory_size:
                        app.errorBox(
                            "Error!", "Too much data was received on the selected serial port.")
                        upload_memcontent = bytes(b'0')
                    else:
                        upload_memcontent = bytes(upload_memcontent_tmp)
                # Close the serial connection after finishing the upload
                ser.close()
            else:
                app.errorBox(
                    "Error!", "Impossible to communicate on the selected serial port.")
    except:
        app.errorBox(
            "Error!", "Impossible to communicate on the selected serial port.")
    # Mark the serial connection as being free again
    serial_free = True
    return

def updateMeters():
    app.setMeter("meter_d1", download_progress)
    app.setMeter("meter_u1", upload_progress)
    return

def downloadSerial(button):
    dwTh = threading.Thread(target=downloadSerialTh)
    dwTh.daemon = True
    dwTh.start()
    return

def uploadSerial(button):
    upTh = threading.Thread(target=uploadSerialTh)
    upTh.daemon = True
    upTh.start()
    return

def clearMemory(button):
    clTh = threading.Thread(target=clearMemoryTh)
    clTh.daemon = True
    clTh.start()
    return

def startExecution(button):
    seTh = threading.Thread(target=startExecutionTh)
    seTh.daemon = True
    seTh.start()
    return

def testSerial():
    ser = serial.Serial(port=app.getOptionBox("list_serial_s"), baudrate=115200,
                        bytesize=8, parity='N', stopbits=1, timeout=0.5, xonxoff=0, rtscts=0)
    ser.reset_input_buffer()
    ser.reset_output_buffer()
    ser.write(testChar)
    s = ser.read(1)
    ser.reset_input_buffer()  # flush input buffer, discarding all its contents
    # flush output buffer, aborting current output and discard all that is in buffer
    ser.reset_output_buffer()
    ser.close()             # close port
    if s == testCharAns:
        return True
    else:
        return False

def testSerialButton(button):
    testTh = threading.Thread(target=testSerialTh)
    testTh.daemon = True
    testTh.start()
    return

def testSerialTh():
    global serial_free
    serial_free = False
    try:
        if not serial_available:
            app.setEntry(
                "entry_s1", 
                "Impossible to test. No serial ports available.", 
                callFunction=False)
        else:
            app.setEntry(
                "entry_s1", 
                "Testing...", 
                callFunction=False)
            testSerial_cnt = 10
            while(not(testSerial())):
                testSerial_cnt = testSerial_cnt - 1
                if testSerial_cnt == 0:
                    break
                time.sleep(0.1)
            if testSerial():
                app.setEntry(
                    "entry_s1", 
                    "The FPGA board is connected to this serial port.", 
                    callFunction=False)
            else:
                app.setEntry(
                    "entry_s1", 
                    "The FPGA board is NOT connected to this serial port.", 
                    callFunction=False)
    except:
        app.errorBox(
            "Error!", "Impossible to communicate on the selected serial port.")
        app.setEntry(
            "entry_s1", 
            "Test if the FPGA board is connected to this serial port.", 
            callFunction=False)
    serial_free = True
    return

def updateTestLabel():
    global current_port
    if current_port != app.getOptionBox("list_serial_s"):
        app.setEntry(
            "entry_s1", 
            "Test if the FPGA board is connected to this serial port.", 
            callFunction=False)
        current_port = app.getOptionBox("list_serial_s")
    return

def updateEnableDisable():
    if download_program == b'0':
        download_program_exists = False
    else:
        download_program_exists = True
    if len(upload_memcontent) != memory_size:
        upload_memcontent_exists = False
    else:
        upload_memcontent_exists = True

    # Start
    # Serial list
    if (serial_available and serial_free):
        app.enableOptionBox("list_serial_s")
    else:
        app.disableOptionBox("list_serial_s")
    # Button: Test
    if serial_available and serial_free:
        app.enableButton("button_s2")
    else:
        app.disableButton("button_s2")
    # Button: Refresh
    if serial_free:
        app.enableButton("button_s1")
    else:
        app.disableButton("button_s1")
    # Button: Open
    if serial_free:
        app.enableButton("button_d1")
    else:
        app.disableButton("button_d1")
    # Button: Download
    if serial_available and serial_free and download_program_exists:
        app.enableButton("button_d3")
    else:
        app.disableButton("button_d3")
    # Button: Download Reset
    if serial_free:
        app.enableButton("button_d4")
    else:
        app.disableButton("button_d4")
    # Button: Upload
    if serial_available and serial_free:
        app.enableButton("button_u3")
    else:
        app.disableButton("button_u3")
    # Button: Upload Reset
    if serial_free:
        app.enableButton("button_u4")
    else:
        app.disableButton("button_u4")
    # Button: Upload save
    if serial_free and upload_memcontent_exists:
        app.enableButton("button_u1")
    else:
        app.disableButton("button_u1")
    # Button: Clear content
    if serial_available and serial_free:
        app.enableButton("button_g1")
    else:
        app.disableButton("button_g1")
    return

################################################################################
# Serial App in Python
# create a GUI variable called app
app = gui("Serial interface")  # S, "500x500")
app.setFont(10)

row = -1

# Setup serial section
row = row + 1
app.addLabel("label_s_title",
             "Setup serial connection to the FPGA board", row, 0, 4)
app.setLabelAlign("label_s_title", "left")

row = row + 1
app.addLabel("label_s1", "Serial port:", row, 0)
app.setLabelAlign("label_s1", "right")
app.addOptionBox("list_serial_s", ["-No serial ports available-"], row, 1, 2)
app.addNamedButton("Refresh list", "button_s1", refreshSerialList, row, 3)

row = row + 1
app.addLabel("label_s2", "Test serial port:", row, 0)
app.setLabelAlign("label_s2", "right")
app.addEntry("entry_s1", row, 1, 2)
app.setEntry(
    "entry_s1", "Test if the FPGA board is connected to this serial port.", callFunction=False)
app.disableEntry("entry_s1")
app.addNamedButton("Test port", "button_s2", testSerialButton, row, 3)

# Row 0
row = row + 1
app.addLabel("label_g1", "Other:", row, 0)
app.setLabelAlign("label_g1", "right")
app.addNamedButton("Clear entire memory content",
                   "button_g1", clearMemory, row, 1, 4)

# Download section
row = row + 1
app.addHorizontalSeparator(row, 0, 4)
row = row + 1
app.addLabel("label_d_title", "Download test program to the FPGA board", row, 0, 4)
app.setLabelAlign("label_d_title", "left")

# Row 0
row = row + 1
app.addLabel("label_d1", "Test program to download:", row, 0)
app.setLabelAlign("label_d1", "right")
app.addEntry("entry_d1", row, 1, 2)
app.setEntryWidth("entry_d1", 60)
app.setEntry("entry_d1", "Select test program to download.", callFunction=False)
app.disableEntry("entry_d1")
app.addNamedButton("Open...", "button_d1", openDownloadFile, row, 3)

# Row 1
row = row + 1
app.addLabel("label_d2", "Actions:", row, 0)
app.setLabelAlign("label_d2", "right")
app.addNamedButton("Download test program", "button_d3", downloadSerial, row, 1)
app.addNamedButton("Reset", "button_d4", resetDownload, row, 3)
# Row 2
row = row + 1
app.addLabel("label_d3", "Download status:", row, 0)
app.setLabelAlign("label_d3", "right")
app.addMeter("meter_d1", row, 1, 3)

# Upload section
row = row + 1
app.addHorizontalSeparator(row, 0, 4)
row = row + 1
app.addLabel("label_u_title", "Upload memory content from the FPGA board", row, 0, 4)
app.setLabelAlign("label_u_title", "left")
# Row 0
row = row + 1
app.addLabel("label_u2", "Actions:", row, 0)
app.setLabelAlign("label_u2", "right")
app.addNamedButton("Upload memory content", "button_u3", uploadSerial, row, 1)
app.addNamedButton("Reset", "button_u4", resetUpload, row, 3)

# Row 2
row = row + 1
app.addLabel("label_u3", "Upload status:", row, 0)
app.setLabelAlign("label_u3", "right")
app.addMeter("meter_u1", row, 1, 3)

# Row 0
row = row + 1
app.addLabel("label_u1", "Save memory content to file:", row, 0)
app.setLabelAlign("label_u1", "right")
app.addEntry("entry_u1", row, 1, 2)
app.setEntry(
    "entry_u1", "Select where to save the uploaded memory content.", callFunction=False)
app.disableEntry("entry_u1")
app.addNamedButton("Save...", "button_u1", saveUploadFile, row, 3)

# Bottom line
row = row + 1
app.addHorizontalSeparator(row, 0, 4)

# Bottom buttons
row = row + 1
app.addButtons(["Help", "About", "Exit"], bottom_press, row, 0, 4)

refreshSerialList(None)
app.registerEvent(updateMeters)
app.registerEvent(updateTestLabel)
app.registerEvent(updateEnableDisable)

app.setResizable(False)

app.setLogLevel("ERROR")

# start the GUI
app.go()