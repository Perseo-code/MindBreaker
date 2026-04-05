# The MsfVenom Module documentation
Welcome to the MsfVenom documentation file! \
This tool is a very easy-to-use hacking kit. If you ever wanted to generate malicious files which connect to your computer and give you full access of the target's computer, this tool uses the msfvenom command for that exact same thing! Since msfvenom can be hard to cope with, this tool I made will make your life easier.

# How to use this script.
You can open it with bash or mindbreaker, your choice. Once you finished starting the program, you will see a command line. \
It will say 'MsfVenom >' Now, you can write commands like:
- help - Show the help
- use (template) - Open a template (You can find all templates in the modules/.config/msfvenom.conf file)
    E.g: use METERPRETER_WINDOWS
- show options - See all available options
- set (variable) - Set a variable to some value.
    E.g: set payload windows/meterpreter_reverse_tcp
- run (once you've filled all variables)

Now that you know all the commands, I'll tell you all options in case of you not running show options:
- payload - This variable is the one that contains the desired payload (meterpreter, reverse shell...).
- LHOST - This variable has to contain your IP address. (Note: If the ip is private and someone enters it through another wifi, you won't be able to access)
- LPORT - This variable contains the port that you'll listen to when the target executes the file.
- encoder - This variable contains the program that will hide the payload from the antiviruses or firewalls. (E.g: x86/shikata_ga_nai) (optional)
- iterations - This variable contains the times you want to encrypt the payload with the encoder. (optional)
- format - This variable contains the format of the file (exe, elf...)
- output - This variable contains the place where the file will be when it finishes generating.