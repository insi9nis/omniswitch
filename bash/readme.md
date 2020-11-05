Bash scripts for AOS 8.x

# How do I use these?

_Examples will use __get-port-info.sh__; replace this with the appropriate file name_

## Option 1: Push the file via sftp

## Option 2: From a CLI prompt:

> vi __get-port-info.sh__

Press __i__ to enter insert mode

Paste the contents of the file

Press __Esc__ to exit insert mode

Type __:wq__ followed by __Enter__ to save and quit

## Either way you get the file there...

From a CLI prompt, mark the file executable

> chmod +x __get-port-info.sh__

## To execute the file, from a CLI prompt

Make sure you're in the directory where you uploaded or created the file, then:

> ./__get-port-info.sh__

If you want to redirect the output to a file, so you can push it elsewhere or pick it up via SFTP:

> ./__get-port-info.sh__ > __port-info.csv__

You may need to be patient while it runs.  You won't see any output until it's done and drops you back at a prompt.
