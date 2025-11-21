# Programming from the Ground Up
## Jonathan Bartlett
### Year 2003


#### Useful Commands

$ as <source-file-name>.s -o <assembled-file-name>.o 

Description: the above "as" runs the "assembler" which "assembles" the assembly source code into machine code, but it isn't runnable just yet, it's just the "object code" that we have to link.

$ ld <assembled-file-name>.o -o <executable-name> note, we don't require any extension in UNIX systems for executables

Description: the above "links" using the "linker" the .o file meaning it completes the object code with metadata/informations required by the Linux kernel in order to run the assembly program.
Like how to load it or how to run it. 
