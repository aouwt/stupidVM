% STUPIDVM(1) stupidVM 3.2.0
% Kit (https://kit.osmarks.net)
% June 2022

# NAME
stupidVM - cycle-accurate modular emulator for stupidVM architecture with a SMP100 processor.

# SYNOPSIS
**stupidVM** \[-v] \[-h] \[-p SO] \[-c SVMRC] \[-m BANK] \[-f FREQ | -F] \[\[-r] ROM]

# DESCRIPTION
**stupidVM** is an emulator designed to emulate a stupidVM architecture with a SMP100 processor at its core. **stupidVM** on its own is nothing more than the backbone of a stupidVM system, most of the I/O, including graphics, sound, keyboard, mouse, etc., is handled via the peripherals, which are loaded at runtime.

# OPTIONS

## GLOBAL OPTIONS
**-h**, **--help**
: Displays a basic help message, then exits.

**-v**, **--version**
: Displays the version of the emulator, then exits.

**-r** *file*, **--rom-file** *file*
: Selects the ROM file to load. Note that this option can be entirely omitted, as any arguments passed that don't start with a hyphen ('-') are assumed to be a ROM file.
: ROM file structure information can be found in svm-rom(5).

**-c** *file*, **--svmrc** *file*
: Use *file* as the svmrc file. If this option is omitted, then **stupidVM** searches in the current directory for svmrc. See svmrc(5) for more information.

**-p** *SO*, **--peripheral** *SO*
: Load *SO* as a peripheral. The location of the file is the same as described in ld.so(8), mostly because I'm lazy.

## VM OPTIONS
**-m** *banks*, **--banks** *banks*
: Sets the amount of memory banks available to the VM to *banks*. Each bank is 32KiB in size, and *banks* can range from 0 to 127. If this option is omitted, it defaults to 127.

**-f** *frequency*, **--frequency** *frequency*
: Sets the main bus frequency to *frequency*, in KHz. If this option is omitted, or if *frequency* is 0, frequency limiting is turned off, and the VM runs as fast as the host system allows it to.

**-F**, **--unlimited**
: Same effect as *-f 0*.

# EXAMPLES
**stupidVM -c ./somedir/svmrc -r ./my.rom**
: Launches **stupidVM**, with ROM file my.rom, utilizing ./somedir/svmrc as the svmrc file. See svmrc(5) for more information.

**stupidVM -f 16000 -m 4 -p ./SAC120.so -p ./SMP100c.so -r ./my.rom**
: Launches **stupidVM**, loading ./SAC120.so and ./SMP100c.so as peripherals, setting the clock speed to 16000KHz (16MHz), and using 4 banks of memory (128KiB).

# BUGS
Report bugs to https://github.com/aouwt/stupidVM/issues

# SEE ALSO
svmrc(5) svm-rom(1) svm-rom(5) stupidVM(5)
