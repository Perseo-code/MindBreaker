# NetCat Module docs

NetCat is a well-known tool in security. This tool is like a Swiss Army knife, you can do:
- Port scanning
- File transfers
- Port Listening/Backdoor
- Network Debugging
- Even a chat server!

This script I made using bash makes its use way easier than to use in the command line. 
There are several options in this script. And here, I'll explain them:
- ZERO-IO (Boolean) - This option scans ports efficiently connecting to them, but sending nothing.
- LISTEN (Boolean) - This option will enable the server mode, which waits until someone connects to them.
- PORT (Number. Will default to 1234) - The port you are going to listen in server mode
- VERBOSE (Boolean) - Will tell more information in general
- NUMERIC (Boolean) - Will avoid DNS resolution, which means you can't use domains, just 'raw' IPs
- EXECUTES (Binary file.) - Will execute a binary in the target's machine
- WAIT (Number) - Adds a timeout
- KEEP-OPEN (Boolean) - Keeps the program open forever until you end it.
- IP (0-255.0-255.0-255.0-255) - (Only works in client mode) Will stablish a connection with the server or computer in the IP you have indicated. 
