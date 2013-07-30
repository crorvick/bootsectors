Disassembly of code used for bootstrapping a PC.  The assembly was
generated from real bootsectors by running something similar to the
below commands and then cleaning up the output.

    $ dd if=/dev/hda of=mbr.img count=1
    $ objdump -b binary -m i386 -D mbr.img

This project is primarily a refresher on how to use the various binutils
utilities to do stuff like this.
