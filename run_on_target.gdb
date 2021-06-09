# this will start gdb, run the following commands

# so we don't bung up the shell output of vscode
set pagination off

# connect to the Open OCD remote gdb server
target ext :3333

# reset and halt the device
monitor reset halt

# read the elf file and symbols
file build/simple-example.elf

# load it onto the target
load

# reset but don't halt so program runs and we can exit
monitor reset

quit
